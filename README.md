# Scrapping NBA Team Statistics (scrapeToCSV.py)
## Overview
This python 3 script scrapes basketball-reference.com/ it order to get full team statistics for all the NBA teams in a given season. Speciifically, these team statistics are placed into CSV files placed in the './data/' directory. An example CSV filename would be: 'teamStats1998.csv' (denotes file containing team stats for all teams in 1998 season). 

## Custom Year Ranges
In the main function within the scrapeToCSV.py file, we can see the following:
```python
# 1998 = start of modern era
startYear = 1998 
endYear = 2018
```
These variables should be changed if a specific subset of statistic CSVs are needed. For, example, the above values cause the script to produce 21 CSV files (one for each of the years withing 1998-2918). 

## Statistics Scraped
The CSV records the following statistics for a given NBA team:
* Team Name (team_name_
* Conference (conf)
* Division (div)
* Wins (win)
* Losses (loss)
* Win/Loss Percentage (win_loss_pct)
* Margin of Victory (mov) 
* Offensive Rating (ortg) - An estimate of points produced (players) or scored (teams) per 100 possessions
* Defensive Rating (drtg) - An estimate of points allowed per 100 possessions
* Net Rating - An estimate of point differential per 100 possessions
* Adjusted Margin of Victory (movA) - Margin of victory adjusted for strength of opponent
* Adjusted Offensive Rating (ortgA) - An estimate of points scored per 100 possessions adjusted for strength of opponent defense
* Adjusted Defensive Rating (drtgA) - An estimate of points allowed per 100 possessions adjusted for strength of opponent offense
* Adjusted Net Rating (nrtgA) - An estimate of point differential per 100 possessions adjusted for strength of opponent
* Team Made Playoffs (plyf) - Binary variable denoting whether the team made the playoffs for the crruent year

## Using the Script
Make sure your python version is 3.5.*:
```
$ python --version
Python 3.5.2 :: Anaconda 4.2.0 (64-bit)
```
Run the script using:
```
$ python ./scrapeToCSV.py
```

# Cluster-Specific Logisitc Regression Models (nbaAnalysis.R)
## Overview
The goal of this analysis is to develop models that can predict whether an NBA team will make the playoffs given the current performance statistics of that team.

## Choosing Logistic Regression Models
Since the NBA teams are the same throughout all 21 seasons (minus a few exceptions), the binary 'plyf' outcome may be highly correlated with the relative team. One example of why this might be true is the fact that the San Antonio Spurs have made the NBA playoffs every single season for the years included in this study (1998-2018). In order to account for this correlation among the observations in the dataset, two modern statistical methods will be used:  
* Random Effects (or cluster-specific, or conditional) models
* Population Averaged (PA) models - These PA models are based on generalized estimating equations GEE, so the models are sometimes labeled as GEEs

## Model Evaluations
This script uses:
* Likelihood Ratio Test - which compares the goodness of fit between two models
* Intraclass Correlation Coefficient - describes how strongly units in the same group resemble each other 

## Using the Script
The best way to use this script is to open it in RStudio. 

## gee() error
For some reason the dataframe created in this R script does not work for the gee() function (evn though it works fine with glmer()). The following error is produced:
```
Beginning Cgee S-function, @(#) geeformula.q 4.13 98/01/27
running glm to get initial regression estimate
 (Intercept) win_loss_pct         movA        nrtgA 
  -26.333691    52.915743    -2.000128     1.557510 
Error in gee(plyf ~ win_loss_pct + movA + nrtgA, family = "binomial",  : 
  Cgee: error: logistic model for probability has fitted value very close to 1.
estimates diverging; iteration terminated.
```
