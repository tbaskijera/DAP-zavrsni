library(readr)
library(dplyr)
library(tidyverse)

data <- read_csv("players_21.csv")
players <- as_tibble(data)
head(players)
summary(players)

yo <- players %>% select(where(is.numeric), "preferred_foot") %>% group_by(preferred_foot) %>% summarize_all(mean) %>% select_if(~ !any(is.na(.)))
View(yo)

# https://www.statology.org/remove-columns-with-na-in-r/

                   