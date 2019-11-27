library(shiny)
# library(leaflet)
# library(maps)
# library(tigris)
# library(sp)
# library(maptools)
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

hf_df <- dbGetQuery(con, paste("SELECT ISO_code, c.CountryName, hf_score, Year=Year(EntryYear) 
                                FROM Entries AS e
                                JOIN Countries as c
                                ON e.Country_ID =c.Country_ID"))



hf_df_2009 <- dbGetQuery(con, paste("
                                  SELECT ISO_code, c.CountryName, hf_score
                                  FROM Entries AS e
                                  JOIN Countries as c
                                  ON e.Country_ID =c.Country_ID
                                  WHERE Year(e.EntryYear) = 2009"))

colorList <- list(color = toRGB("grey"), width = 0.5)

m_options <- list(showframe = FALSE, showcoastlines = FALSE, 
                  projection = list(type = 'Mercator'))



# plot_geo(hf_df_2009) %>% 
#   add_trace(
#     z = ~hf_score, 
#     color = ~hf_score,
#     colors = 'Blues',
#     text = ~CountryName,
#     locations = ~ISO_code,
#     marker = list(line = colorList)
#   ) %>% 
#   colorbar(title = "Human Freedom Score") %>% 
#   layout(
#     title = "Human Freedom Score in 2009",
#     geo = m_options
#   )
 

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
  
  
  output$staticHF <- renderLeaflet({
    plot_geo(hf_df_2009) %>%
      add_trace(
        z = ~hf_score,
        color = ~hf_score,
        colors = 'Blues',
        text = ~CountryName,
        locations = ~ISO_code,
        marker = list(line = colorList)
      ) %>%
      colorbar(title = "Human Freedom Score") %>%
      layout(
        title = "Human Freedom Score in 2009",
        geo = m_options
      )
    
  })
  
  hf_df_react <- reactive({
    year_selection <- hf_df %>% 
      filter(Year == input$select_year)
  })
  
  
  
  # output$datatable <- renderDataTable({
  #   hf_df_react()
  # })
  output$dynamicHF <-renderPlotly({
    updated_hf_df <- hf_df_react()
    
    u_df_df <- plot_geo(updated_hf_df) %>%
      add_trace(
        z = ~hf_score,
        color = ~hf_score,
        colors = 'Blues',
        text = ~CountryName,
        locations = ~ISO_code,
        marker = list(line = colorList)
      ) %>%
      colorbar(title = "Human Freedom Score") %>%
      layout(
        title = "Human Freedom Score in 2009",
        geo = m_options
      )
    
  })
  
}