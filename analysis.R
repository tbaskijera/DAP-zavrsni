# install.packages('readr')
# install.packages('dplyr')
# install.packages('caret')
library(readr)
library(dplyr)
library(caret)
library(stringr)


data <- read_csv("./players_21.csv")
players <- as_tibble(data)
head(players)
summary(players)

# Predprocesiranje - Agregacija
positions = unique(players["team_position"]) # sve jedinstvene pozicije
attack= c("LS", "ST", "LW", "RW", "CF", "RS", "LF", "RF")
midfield = c("CAM", "RCM", "CDM", "RDM", "LCM", "LM", "RM", "LDM", "LAM", "RAM")
defence = c("LCB", "RB", "LB", "RCB", "LCB", "CB", "LWB", "RWB")

declare_role <- function(position) {
  if (position %in% attack) { return ("attacker") }
  if (position %in% midfield) { return ("midfielder") }
  if (position %in% defence) { return ("defender") }
  if (position %in% c("GK")) { return ("goalkeeper") }
  else { return ("unknown") }
}

players_modified <- players %>% mutate(role = sapply(team_position, declare_role))

role_groups <- players_modified %>% 
  select(where(is.numeric), "role") %>% 
  group_by(role) %>% 
  summarize_all(mean) %>% 
  select_if(~ !any(is.na(.)))
role_groups # mozda treba ocistit sofifaid i tako neka polja?

# Klasifikacija - Umjetne neuronske mreže
df <- players_modified %>%
  # tu u liniji 38 ako cemo mozemo jos dodavat, brisat, mjenjat, ovisno koliko cemo da nam bude tocnost...
  select("role", "defending", "attacking_finishing", "movement_agility", "shooting") %>% 
  filter(role!="unknown")
df <- na.omit(df)

indexes <- createDataPartition(y = df$role, p = .8, list = FALSE)
train <- df %>% slice(indexes)
test <- df %>% slice(-indexes)
train_index <- createFolds(train$role, k = 10)

nnetFit <- train %>% train(role ~ .,
                           method = "nnet",
                           data = .,
                           tuneLength = 5,
                           trControl = trainControl(method = "cv", indexOut = train_index))
nnetFit
prediction <- predict(nnetFit, test)
prediction
cmatrix <- confusionMatrix(factor(prediction), factor(test$role))
cmatrix

# Klasifikacija - Umjetne šume
control <- trainControl(method = "repeatedcv",
                         number = 3,
                         repeats = 5)
modelRF <- train(role ~ .,
               data = train,
               method = "rf",
               preProcess = c("scale", "center"),
               trControl = control,
               verbose = FALSE)
prediction <- predict(modelRF, test)
prediction
cmatrix <- confusionMatrix(factor(prediction), factor(test$role))
cmatrix

# Asocijacijska analiza - vizualizacija asocijacijskih pravila
vis_db <- players_modified[,c(3, 15, 107, 20, 21, 34:38, 9, 12, 11, 27)]
vis_db$weak_foot<-ifelse(vis_db[,4]<3, "poor weak foot", ifelse(vis_db[,4]<4, "average weak foot", ifelse(vis_db[,4]<6, "above average weak foot", NA)))
vis_db$skill_moves<-ifelse(vis_db[,5]<3, "low_skills", ifelse(vis_db[,5]<4, "average_skils", ifelse(vis_db[,5]<6, "high_skills", NA)))
vis_db$pace<-ifelse(vis_db[,6]<74, "poor pace", ifelse(vis_db[,6]<87, "average pace", ifelse(vis_db[,6]<98, "above average pace", NA)))
vis_db$shooting<-ifelse(vis_db[,7]<73, "poor shooting", ifelse(vis_db[,7]<82, "average shooting", ifelse(vis_db[,7]<94, "above average shooting", NA)))
vis_db$passing<-ifelse(vis_db[,8]<66, "poor passing", ifelse(vis_db[,8]<82, "average passing", ifelse(vis_db[,8]<94, "above average passing", NA)))
vis_db$dribbling<-ifelse(vis_db[,9]<78, "poor dribbling", ifelse(vis_db[,9]<87, "average dribbling", ifelse(vis_db[,9]<96, "above average dribbling", NA)))
vis_db$defending<-ifelse(vis_db[,10]<45, "poor defense", ifelse(vis_db[,10]<81, "average defense", ifelse(vis_db[,10]<96, "above average defense", NA)))
trans <- as(vis_db, "transactions")
rul <- apriori(trans, parameter = list(supp = 0.5, conf = 0.5, minlen = 2))
rul
plot(rul, method="grouped", measure="support", shading="lift")

transactions <- as(players_modified, "transactions")
rules <- apriori(transactions, parameter = list(supp = 0.5, conf = 0.5, minlen = 2))
rules
inspect(rules)
plot(rules, method = "graph")
plot(rules, shading = "order", jitter=0)
plot(rules, method = "grouped", by="prefered_foot")
plot(head(rules, by = "prefered_foot", n = 100), method = "graph")
plot(rules, method="grouped", measure="support", shading="lift")

# Grupiranje - grupiranje k-sredina
#install.packages("plotly") # za interaktivan prikaz
library(plotly)
library(ggplot2)

k_means_fifa <- players_modified[,c(34:45, 47:80)]
# ako je neka vrijednost NA zamijenjuje se sa 1
k_means_fifa[is.na(k_means_fifa)] <-1

set.seed(123)
model <- kmeans(k_means_fifa, 3)
table(clusters$cluster)

results <- as.data.frame(cbind(players_modified[3], cluster=model$cluster, players_modified[107]))
head(results[results$cluster == 1,],15) # defender
head(results[results$cluster == 2,],15) # attacker + midfielder
head(results[results$cluster == 3,],15) # goalkeeper

ggplot(k_means_fifa, aes(x=defending, y= shooting, col= as.factor(model$cluster))) + geom_point()
visualisation <- ggplot(k_means_fifa, aes(x=defending_standing_tackle, y= attacking_finishing, col= as.factor(model$cluster))) + geom_point()
ggplotly(visualisation)
# moze se nacrtat i neki drugi skup
ggplot(k_means_fifa, aes(x=skill_dribbling, y= power_strength, col= as.factor(model$cluster))) + geom_point()


# 
# # Klasifikacija - Umjetne neuronske mreže
# players_modified <- players %>% mutate(player_positions=sapply(strsplit(player_positions, ","), "[", 1))
# players_modified <- players_modified %>% 
#   select("player_positions", "skill_dribbling", "skill_ball_control", "movement_acceleration", "movement_sprint_speed")
# players_modified <- players_modified[1:9000, ]
# 
# indexes <- createDataPartition(y = players_modified$player_positions, p = .8, list = FALSE)
# train <- players_modified %>% slice(indexes)
# test <- players_modified %>% slice(-indexes)
# train_index <- createFolds(train$player_positions, k = 10)
# 
# 
# colSums(is.na(players_modified))
# players_modified
# 
# 
# nnetFit <- train %>% train(player_positions ~ .,
#                            method = "nnet",
#                            data = .,
#                            tuneLength = 5,
#                            trControl = trainControl(method = "cv", indexOut = train_index))
# 
# 
# nnetFit
# 
# pr <- predict(nnetFit, test)
# pr
# 
# y <- confusionMatrix(factor(pr), factor(test$player_positions))
# y
