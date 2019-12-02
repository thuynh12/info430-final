library(shiny)
library(odbc)
library(DBI)
library(dplyr)
library(RJDBC)
library(plotly)
library(shinythemes)

# connect to data source

# UNCOMMENT FOR MAC
con <- DBI::dbConnect(odbc::odbc(), Driver = "ODBC Driver 13 for SQL Server", Server = "is-info430.ischool.uw.edu",
                      Database = "Group4-Final", UID = "INFO430", PWD = "wubalubadubdub",
                      Port = 1433)

# UNCOMMENT FOR WINDOWS
# con <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "is-info430.ischool.uw.edu", 
#                       Database = "Group4-Final", UID = "INFO430", PWD = "wubalubadubdub", 
#                       Port = 1433)

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


allCodes <- dbGetQuery(con, paste("
                                  SELECT e.hf_score, e.ef_score, e.pf_score, hfi.ef_legal_military, 
                                  hfi.pf_expression, hfi.pf_religion, CountryName, Year=Year(EntryYear)
                                  FROM [human-freedom-index] As hfi
                                  JOIN Entries As e 
                                  ON hfi.hf_score = e.hf_score
                                  JOIN Countries As c
                                  On e.Country_ID = c.Country_ID",
                                  sep=""))


<<<<<<< HEAD

all <- dbGetQuery(con, paste("
                                SELECT ISO_Code, O.CountryName, Year=Year(E.EntryYear), hf_rank, hf_quartile, hf_score, 
                                ef_score, ef_legal_military, pf_expression, pf_religion
                                FROM Entries as E
                                JOIN Countries as O
                                ON E.Country_ID = O.Country_ID",
                                sep=""))
allCols <- colnames(all)
allIDS <- allCols[6:10]

=======
test <- allCodes %>% 
  filter(Year == 2009 & CountryName == 'Iran')
>>>>>>> c030a4ab0d5d1217d156dad8dda44f3cc4901656

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
  
  #add reactive data information. Dataset = built in diamonds data
  dataset <- reactive({
    yearCountrySub <- allCodes %>% 
      filter(Year == input$selected_year & CountryName == input$select_country)
  })
  
  output$trendPlot <- renderPlotly({
    df <- dataset()
    p <- plot_ly(df, 
      x = c('hf_score', 'ef_score', 'pf_score', 'ef_legal_military', 'pf_expression', 'pf_religion'),
      y = c(~hf_score, ~ef_score, ~pf_score, ~ef_legal_military, ~pf_expression, ~pf_religion),
      type = 'bar'
    ) %>% 
      layout(
        title = paste('Freedom Scores in', input$select_country,'in', input$selected_year),
        xaxis = list(
          type = 'category',
          title = 'Type of Freedom Score'
        ),
        yaxis = list(
          title = 'Score (Ranging from 0-10)',
          range = c(0, 10)
        )
      )
    
    
  })
  
  
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
  
  
  output$staticHF <- renderPlotly({
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
  
  
  ByIdAndYear <- reactive({
    subset_all <- all %>% 
      select(ISO_Code, CountryName, Year, input$select_id) %>% 
      filter(Year == input$select_mapyear)
    # this_id <- input$select_id
  })
  
  output$dynamicMapScore <- renderPlotly({
    sub <- ByIdAndYear()
    
    plot_geo() %>%
      add_trace(
        z = ~sub[[4]],
        color = ~sub[[4]],
        colors = 'Reds',
        text = ~sub$CountryName,
        locations = ~sub$ISO_Code,
        marker = list(line = colorList)
      ) %>%
      colorbar(title = input$select_id) %>%
      layout(
        title = paste("Map of", input$select_id, "in year", input$select_mapyear),
        geo = m_options
      )
    
  })
  
}