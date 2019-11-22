library(shiny)
library(odbc)
library(DBI)
library(dplyr)
library(RJDBC)
library(plotly)
library(shinythemes)

# connect to data source
con <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "is-info430.ischool.uw.edu", 
                      Database = "Group4-Final", UID = "INFO430", PWD = "wubalubadubdub", 
                      Port = 1433)

# query data source to get all entries with the countryName, year and scores
entry <- dbGetQuery(con, paste("
    SELECT hf_score, ef_score, pf_score, CountryName, EntryYear
                               FROM Entries As e
                               Inner Join Countries As c
                               On e.Country_ID = c.Country_ID", 
                               sep=""))

server <- function(input, output) {
  
  # scatter plot of economic and personal freedom vs human freedom (with trend lines)
  output$scatterPlot1 <- renderPlotly({
    
    # create ployly scatter plot
    plot_ly(entry, x = ~hf_score, text = ~paste("Country: ", CountryName, '<br>Year:', EntryYear)) %>%
      add_trace(y = ~pf_score, name = 'Personal Freedom', mode = 'markers', type = 'scatter') %>%
      add_trace(y = ~ef_score, name = 'Economic Freedom', mode = 'markers', type = 'scatter') %>%
      add_trace(entry, x = ~hf_score, y = ~fitted(lm(pf_score ~ hf_score, entry)), type = 'scatter', 
                name = "Personal Freedom <br> Trend Line", mode = "lines",
                line = list(color = 'rgb(66,190,216)')) %>%
      add_trace(entry, x = ~hf_score, y = ~fitted(lm(ef_score ~ hf_score, entry)), type = 'scatter',
                name = "Economic Freedom <br> Trend Line", mode = "lines",
                line = list(color = 'rgb(253,198,131)')) %>%
      layout(title = "Economic and Personal Freedom vs. Human Freedom", 
             xaxis = list(title = "Human Freedom Score"), yaxis = list(title = "Freedom Score"))
  })
  
}