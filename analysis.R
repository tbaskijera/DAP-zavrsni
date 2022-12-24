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
ctreeFit <- train %>% train(role ~ ., # myb bi trebalo za neke druge podatke, ili myb za iste ko sta je pa da usporedimo dve metode kao?
                            method = "ctree",
                            data = .,
                            tuneLength = 5,
                            trControl = trainControl(method = "cv", indexOut = train_index))
ctreeFit
prediction <- predict(ctreeFit, test)
prediction
cmatrix <- confusionMatrix(factor(pr), factor(test$role))

# Asocijacijska analiza - vizualizacija asocijacijskih pravila

# Grupiranje - grupiranje k-sredina



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
