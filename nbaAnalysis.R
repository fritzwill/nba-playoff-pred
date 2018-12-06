# # uncomment below to combine data set from csv files produced by the python scraper
# # create df of all csvs in ./data/ directory
# filenames <- list.files(path="./data/", pattern="*.csv")
# filenames <- paste('./data/', filenames, sep='')
# df <- do.call(rbind, lapply(filenames, function(x) read.csv(x, stringsAsFactors = F)))
# 
# # give each team its correct historic data (must be done because of team_name changes throughout the years)
# df$team_name[df$team_name == "Seattle SuperSonics"] <- "Oklahoma City Thunder"
# df$team_name[df$team_name == "Charlotte Bobcats"] <- "Charlotte Hornets"
# df$team_name[df$team_name == "New Jersey Nets"] <- "Brooklyn Nets"
# df$team_name[df$team_name == "New Orleans/Oklahoma City Hornets"] <- "New Orleans Pelicans"
# df$team_name[df$team_name == "New Orleans Hornets"] <- "New Orleans Pelicans"
# df$team_name[df$team_name == "Vancouver Grizzlies"] <- "Memphis Grizzlies"
# 
# write.csv(df, file="./data/teamStats1998-2018.csv")

# comment above and uncomment below if we already generated joint csv
df <- read.csv("./data/teamSats1998-2017.csv")

## First we will attempt a Population average model
## (performing a GEE analysis of data)
library(gee)
df.clusterOrder <- df[order(df$team_name),]
mod.gee <- gee(plyf~win_loss_pct+movA+nrtgA, family="binomial", id=team_name, corstr="unstructured", tol=0.01, data=df.clusterOrder)


## Next we will atttempt random cluster