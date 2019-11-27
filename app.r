library(shiny)
library(odbc)
library(DBI)
library(dplyr)
library(RJDBC)
library(plotly)
library(shinythemes)

# retrieve server variable and plot information
source("source.r")


# Define UI for app that draws a histogram ----
ui <- navbarPage(theme = shinytheme("journal"), "INFO 430",
                 
  # create tab for scatter plot with personal/economic freedoms
  tabPanel("Scatter", 
      titlePanel("Personal and Economic Freedom"),
      p("This scatter plot explores the relationship between personal freedom scores, economic 
        freedom scores and human freedom scores. The plot contains scores from all countries
        for years 2008 - 2016. The scatter plot shows that both personal and economic scores 
        have a positive coorelation with human freedom scores. This means that the human freedom 
        score increases when economic and personal freedom scores increase."),
      plotlyOutput("scatterPlot1")
           
  ), 
  
  # create placeholder tab
  tabPanel("Summary", 
      titlePanel("Summary"),
      h3("Placeholder information"),
      p("This is a summary of the project")
      
  ),
  # create tab for HF Map
  tabPanel("Human Freedom Scores", 
    titlePanel("Human Freedom Score"),
    h3("Static"),
    plotlyOutput("staticHF"),
    h3("Human Freedom Scores By Year"),
    selectInput('select_year',
                label = "Select Year",
                choices = unique(hf_df$Year),
                selected = 2008
      ),
    # dataTableOutput("datatable")
    plotlyOutput("dynamicHF")
    # p("This is a summary of the project")
    
    
  )
  
)


shinyApp(ui = ui, server = server)

