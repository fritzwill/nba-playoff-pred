from urllib.request import urlopen
from bs4 import BeautifulSoup
import csv

def writeCSV(filename, rows, colNames):
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(colNames)
        for row in rows:
            cells = row.find_all('td')
            cellVals = [x.text for x in cells]
            writer.writerow(cellVals)

if __name__ == "__main__":
    # 1998 = start of modern era
    startYear = 1998 
    endYear = 2017
    years = [yr for yr in range(startYear,endYear+1)]
    urls = ["https://www.basketball-reference.com/playoffs/NBA_{}.html".format(yr) for yr in years]
    dataDir = 'data/'

    for i, url in enumerate(urls):
        page = urlopen(url).read()
        soup = BeautifulSoup(page, 'html.parser')

        # find the rows of data we want
        statsPerGame = soup.find("div", {"id": "all_team-stats-per_game"})
        statsPerGameTbl = statsPerGame.find('tbody')
        rows = statsPerGameTbl.find_all('tr')

        # generate csv for specific year
        filename = dataDir + "teamStats{}.csv".format(startYear+i)
        colNames = ['team_name', 'g','mp', 'fg','fga','fg_pct','fg3', 'fg3a','fg3_pct','fg2','fg2a','fg2_pct','ft','fta','ft_pct','orb','drb','trb','ast','stl','blk','tov','pf','pts']
        writeCSV(filename, rows, colNames)





        
        