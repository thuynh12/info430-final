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


all <- dbGetQuery(con, paste("
                                SELECT ISO_Code, O.CountryName, Year=Year(E.EntryYear), hf_rank, hf_quartile, hf_score, 
                                ef_score, pf_score, ef_legal_military, pf_expression, pf_religion
                                FROM Entries as E
                                JOIN Countries as O
                                ON E.Country_ID = O.Country_ID",
                                sep=""))
allCols <- colnames(all)
allIDS <- allCols[6:10]





# Settings for color 
colorList <- list(color = toRGB("grey"), width = 0.5)
m_options <- list(showframe = FALSE, showcoastlines = FALSE, 
                  projection = list(type = 'Mercator'))


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
      type = 'bar', 
      marker = list(color = 'rgb(158,202,225)',
                    line = list(color = 'rgb(8,48,107)',
                                width = 1.5))
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
        ),
        height = 500,
        width= 900
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
             xaxis = list(title = "Human Freedom Score"), yaxis = list(title = "Freedom Score"), height = 900, width = 1000)
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
        title = paste("Human Freedom Score in", input$select_year),
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
  
  queryTable <- reactive({
    tb_year <- all %>% 
      select(CountryName, Year, hf_rank, hf_score, ef_score, pf_score) %>% 
      filter(Year == input$select_tbyear & hf_rank != 0) %>% 
      arrange(hf_rank)
  })
  
  output$dynamicTable <- renderPlotly({
    ranking <- queryTable()
    
    plot_ly(
      type = 'table',
      header = list(
        values = c("Country", "Rank", "Human Freedom Score", "Economic Freedom Score", "Personal Freedom Score"),
        align = c("center", "center"),
        line = list(width = 1, color = 'black'),
        fill = list(color = c("grey", "grey")),
        font = list(family = "Arial", size = 14, color = "white")
      ),
      cells = list(
        values = rbind(ranking$CountryName, ranking$hf_rank, ranking$hf_score, ranking$ef_score, ranking$pf_score),
        align = c("center", "center"),
        line = list(color = "black", width = 1),
        font = list(family = "Arial", size = 12, color = c("black")
        ))
    )
  })
  
  output$summaryTable <- renderPlotly({
    
    values <- rbind(c('Human Freedom Score', 'Personal Freedom Score', 'Economic Freedom Score', 'Legal Military Score', 
                      'Personal Freedom of Expression Score', 'Personal Freedom of Religion Score'),
                    c("hf_score", 
                      "pf_score", 
                      "ef_score", 
                      "ef_legal_military", 
                      "pf_expression",
                      "pf_religion"),
                    c(1, 
                      2, 
                      3, 
                      4, 
                      5,
                      6))
    
    p <- plot_ly(
      type = 'table',
      columnorder = c(1, 2, 3),
      columnwidth = c(100, 100, 400),
      header = list(
        values = c('Type of Score', 'Abbreviation','Description'),
        line = list(color = 'black'),
        fill = list(color = '#119DFF'),
        align = c('left','center'),
        font = list(color = 'white', size = 12),
        height = 40
      ),
      cells = list(
        values = values,
        line = list(color = '#506784'),
        fill = list(color = c('#25FEFD', 'white')),
        align = c('left', 'center'),
        font = list(color = c('#506784'), size = 12),
        height = 30
      ))
  })
  
  
  
}