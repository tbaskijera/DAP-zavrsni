install.packages('readr')
install.packages('dplyr')
install.packages('caret')
install.packages('plotly')
install.packages('randomForest')
install.packages('arulesViz')
install.packages('RColorBrewer')
library(RColorBrewer)
library(arulesViz)
library(randomForest)
library(plotly)
library(ggplot2)
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
  select("role", "defending", "attacking_finishing", "movement_agility", "shooting", "passing") %>% 
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
vis_db <- players_modified[,c(3, 107, 20, 21, 34:38)]
vis_db$weak_foot<-ifelse(vis_db[,3]<3, "poor weak foot", ifelse(vis_db[,3]<4, "average weak foot", ifelse(vis_db[,3]<6, "above average weak foot", NA)))
vis_db$skill_moves<-ifelse(vis_db[,4]<3, "low skills moves", ifelse(vis_db[,4]<4, "average skils moves", ifelse(vis_db[,4]<6, "high skills moves", NA)))
vis_db$pace<-ifelse(vis_db[,5]<74, "poor pace", ifelse(vis_db[,5]<87, "average pace", ifelse(vis_db[,5]<98, "above average pace", NA)))
vis_db$shooting<-ifelse(vis_db[,6]<73, "poor shooting", ifelse(vis_db[,6]<82, "average shooting", ifelse(vis_db[,6]<94, "above average shooting", NA)))
vis_db$passing<-ifelse(vis_db[,7]<66, "poor passing", ifelse(vis_db[,7]<82, "average passing", ifelse(vis_db[,7]<94, "above average passing", NA)))
vis_db$dribbling<-ifelse(vis_db[,8]<78, "poor dribbling", ifelse(vis_db[,8]<87, "average dribbling", ifelse(vis_db[,8]<96, "above average dribbling", NA)))
vis_db$defending<-ifelse(vis_db[,9]<45, "poor defense", ifelse(vis_db[,9]<81, "average defense", ifelse(vis_db[,9]<96, "above average defense", NA)))

trans <- as(vis_db, "transactions")
rul <- apriori(trans, parameter = list(supp = 0.2, conf = 0.5, minlen = 5))
rul
inspect(rul)
plot(rul, method="grouped", measure="support", shading="lift")
plot(head(sort(rul, by = "lift"), n=50), method = "graph")
itemFrequencyPlot(trans, topN=25, col=brewer.pal(12, 'Set3'), type="relative", main="Frequency Plot")
plot(rul, method="paracoord", control=list(reorder=TRUE))


# Grupiranje - grupiranje k-sredina
k_means_fifa <- players_modified[,c(34:45, 47:80)]
# ako je neka vrijednost NA zamijenjuje se sa 1
k_means_fifa[is.na(k_means_fifa)] <-1
set.seed(123)
model <- kmeans(k_means_fifa, 3)

results <- as.data.frame(cbind(players_modified[3], cluster=model$cluster, players_modified[107]))
head(results[results$cluster == 1,],15) # defender
head(results[results$cluster == 2,],15) # goalkeeper 
head(results[results$cluster == 3,],15) # attacker + midfielder

ggplot(k_means_fifa, aes(x=defending, y= shooting, col= as.factor(model$cluster))) + geom_point()
visualisation <- ggplot(k_means_fifa, aes(x=defending_standing_tackle, y= attacking_finishing, col= as.factor(model$cluster))) + geom_point()
ggplotly(visualisation)
# moze se nacrtat i neki drugi skup
visualisation2 <- ggplot(k_means_fifa, aes(x=skill_dribbling, y= power_strength, col= as.factor(model$cluster))) + geom_point()
ggplotly(visualisation2)