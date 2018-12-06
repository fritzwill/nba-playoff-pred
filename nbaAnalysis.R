##
##
########## START HERE IF NEED TO GENERATE MULTIPLE SEASON CSV ############
##
##
# uncomment below to combine data set from csv files produced by the python scraper
# create df of all csvs in ./data/ directory
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
# # 
# write.csv(df, file="./data/teamStats1998-2018.csv")

##
##
########### START HERE IF ALREADY HAVE MULTIPLE SEASON CSV ###########
##
##
# comment above and uncomment below if we already generated joint csv
df <- read.csv("./data/teamStats1998-2018.csv", stringsAsFactors = F)
df$X <-NULL #do not want this column (index)

#### First we will atttempt cluster specific (random effects) ####
library(lme4)
df$team_name <- as.factor(df$team_name)

colNames<- colnames(df)
print("Possible covariates:")
print(colNames)

# random intercept (use cluster variable of team_name)
mod.randInt <- glmer(plyf~win_loss_pct+movA+nrtgA+(1|team_name), family = binomial, data=df)

# random intercept and trend
mod.randIntTrend.wl <- glmer(plyf~win_loss_pct+movA+nrtgA+(1+win_loss_pct|team_name), family = binomial, data=df)
mod.randIntTrend.mov <- glmer(plyf~win_loss_pct+movA+nrtgA+(1+movA|team_name), family = binomial, data=df)
mod.randIntTrend.nrtg <- glmer(plyf~win_loss_pct+movA+nrtgA+(1+nrtgA|team_name), family = binomial, data=df)

# get std. deviation values 
VarCorr(mod.randIntTrend.wl)
VarCorr(mod.randIntTrend.mov)
VarCorr(mod.randIntTrend.nrtg)

# clacl ICC (intraclass correlation coefficient)
icc.wl <- (2.647^2/(2.647^2+(pi^2/3)))
icc.mov <- (0.10027^2/(0.10027^2+(pi^2/3)))
icc.nrtg <-(0.073607^2/(0.073607^2+(pi^2/3)))

# get predicted rand. intercepts
rand_ints.wl <- unlist(ranef(mod.randIntTrend.wl)$team_name)
rand_ints.mov <- unlist(ranef(mod.randIntTrend.mov)$team_name)
rand_ints.nrtg <- unlist(ranef(mod.randIntTrend.nrtg)$team_name)

## conduct Liklihood Ratio Test for each model
# calc deviance
baseDev <- getME(mod.randInt, "devcomp")$cmp[["dev"]]
testDev.wl <- getME(mod.randIntTrend.wl, "devcomp")$cmp[["dev"]]
testDev.mov <- getME(mod.randIntTrend.mov, "devcomp")$cmp[["dev"]]
testDev.nrtg <- getME(mod.randIntTrend.nrtg, "devcomp")$cmp[["dev"]]
# calc degrees of freedom
baseDf <- attr(logLik(mod.randInt), "df")
testDf.wl <- attr(logLik(mod.randIntTrend.wl), "df")
testDf.mov <- attr(logLik(mod.randIntTrend.mov), "df")
testDf.nrtg <- attr(logLik(mod.randIntTrend.nrtg), "df")
# calc p-vals
print("W/L%:")
pchisq(baseDev-testDev.wl, testDf.wl-baseDf, lower=F)
print("mov:")
pchisq(baseDev-testDev.mov, testDf.mov-baseDf, lower=F)
print("nrtg:")
pchisq(baseDev-testDev.nrtg, testDf.nrtg-baseDf, lower=F)



## Next, we will attempt a Population average model
## (performing a GEE analysis of data)
library(gee)

# we must take the Spurs out of the dataframe since they have made the playoffs every single year since 1998
# thus, the model cannot be fit properly since there is no knowledge about the Spurs not making the playoff
df.clusterOrder <- df[order(df$team_name),]
df.clusterOrder$team_name <- as.factor(df.clusterOrder$team_name)

###### gee() DOES NOT WORK ##########

#mod.gee <- gee(plyf~win_loss_pct+movA+nrtgA, family="binomial", id=team_name, corstr="exchangeable", data=df.clusterOrder)

####### NOTE #######
## the above gee() command gives the following error:
# Error in gee(plyf ~ win_loss_pct + movA + nrtgA, family = "binomial",  : 
#   Cgee: error: logistic model for probability has fitted value very close to 1.
# estimates diverging; iteration terminated.

# fit gneral logistic model and display histogram of fitted valus
df.glm <- glm(formula = plyf ~ win_loss_pct + movA + nrtgA, family = binomial, data = df.clusterOrder)
hist(df.glm$fitted.values)
