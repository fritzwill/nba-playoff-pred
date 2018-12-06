from urllib.request import urlopen
from bs4 import BeautifulSoup
import csv

def writeCSV(filename, rows, rowsPlyf, colNames):
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(colNames)
        plyfTeams = [row.find('td').text for row in rowsPlyf if row.find('td').text != 'League Average']
        plyfTeams = [team.lower() for team in plyfTeams]
        totalPlyfTeams = 0
        for i, row in enumerate(rows):
            cells = row.find_all('td')
            plyf = 0
            teamName = cells[0].string.lower()
            if teamName == "charlotte bobcats":
                if "charlotte hornets" in plyfTeams:
                    plf =1
                    totalPlyfTeams += 1
            if teamName in plyfTeams:
                plyf = 1
                totalPlyfTeams += 1
            cellVals = [x.text for x in cells]
            cellVals.append(plyf)
            writer.writerow(cellVals)

        if totalPlyfTeams != 16:
            print("ERROR file [{}]: the number of plyf teams scraped [{}] is not 16".format(filename, totalPlyfTeams))
            exit(1)

if __name__ == "__main__":
    # 1998 = start of modern era
    startYear = 1998 
    endYear = 2018
    years = [yr for yr in range(startYear,endYear+1)]
    urlsStats = ["https://www.basketball-reference.com/leagues/NBA_{}_ratings.html".format(yr) for yr in years]
    urlsPlyf = ["https://www.basketball-reference.com/playoffs/NBA_{}.html".format(yr) for yr in years]
    dataDir = 'data/'

    for i, url in enumerate(urlsStats):
        ## handle basic stats ##
        page = urlopen(url).read()
        soup = BeautifulSoup(page, 'html.parser')

        # find the rows of data we want
        statsPerGame = soup.find("div", {"id": "all_ratings"})
        statsPerGameTbl = statsPerGame.find('tbody')
        rows = statsPerGameTbl.find_all('tr')

        ## handle plyf 
        pagePlyf = urlopen(urlsPlyf[i]).read()
        soupPlyf = BeautifulSoup(pagePlyf, 'html.parser')

        teamStatsPerGame = soupPlyf.find("div",{"id":"all_team-stats-per_game"})
        teamStatsPerGameTbl = teamStatsPerGame.find('tbody')
        rowsPlyf = teamStatsPerGameTbl.find_all('tr')

        # generate csv for specific year
        filename = dataDir + "teamStats{}.csv".format(startYear+i)
        colNames = ['team_name', 'conf','div', 'win','loss','win_loss_pct','mov', 'ortg','drtg','ntrg','movA','ortgA','drtgA','nrtgA', 'plyf']
        writeCSV(filename, rows, rowsPlyf, colNames)






        
        