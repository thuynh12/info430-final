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
ui <- navbarPage(theme = shinytheme("flatly"), "INFO 430",
  
  tabPanel("Summary", 
      titlePanel("--"),
      mainPanel(
      h1("Problem Statement"),
      p("It is uncommon for news outlets in the United States to discuss events occurring 
        in different parts of the world. After conducting a global survey, the Pew Research   
        Center discovered that the global median said \"they follow news about their country
        (86%) or city and town (78%) closely,compared with fewer than six-in-ten who say the  
        same when it comes to news about other countries generally (57%)\". This presents a  
        problem because it forms a demographic that becomes ignorant to world events that   
        have the potential to impact their country. Without the ability to make informed  
        decisions, citizens are unable to acquire the knowledge necessary to determine who  
        to vote for in elections and do not understand what is occuring in the rest of the world."),
      h1("Where is this data coming from?"),
      p("For our data, we will use the Human Freedom Index dataset from the Cato Institution. 
        This dataset looks at every country from 2008 to 2016 and gives each country a human  
        freedom score ranging from zero to ten. The dataset also gives scores that encompasses  
        personal, civil, and economic freedoms. In order to focus our analysis we will only be  
        looking at Hf_score (human freedom score), pf_score (personal freedom score), ef_score  
        (economic freedom score), ef_legal_military (legal military score), pf_expression (freedom  
        of expression score) and pf_religion (freedom of religion score). Our solution values the   
        understanding of these rights within countries and is vital when looking at different events  
        occurring throughout the world to help understand global affairs."),
      p("The Cato Institute is a public policy research organization dedicated to the principles 
        of individual liberty, limited government, free markets and peace. Everyone is provided   
        with free access to download the reports and datasets surrounding their Human Freedom Index.  
        The data is very holistic and gives us a wide range of information to work with."),
      h1("What are we trying to do?"),
      p("The main goal of our project is to spread awareness and educate people about 
        the level of freedoms around the world this data alone will be sufficient for analysis,   
        visualization, and documentation. Because of the nature of our topic and data we will   
        not be taking user-submitted data.")
      )
  ),               
     
  # create tab for scatter plot with personal/economic freedom
  tabPanel("Scatter", 
      titlePanel("Personal and Economic Freedom"),
      sidebarPanel(position = 'left'),
      mainPanel(
      p("This scatter plot explores the relationship between personal freedom scores, economic 
        freedom scores and human freedom scores. The plot contains scores from all countries
        for years 2008 - 2016. The scatter plot shows that both personal and economic scores 
        have a positive coorelation with human freedom scores. This means that the human freedom 
        score increases when economic and personal freedom scores increase."),
      plotlyOutput("scatterPlot1")
      )     
  ), 
  
  # create placeholder tab
  tabPanel("Bar Chart",
           titlePanel("Interactive Bar Chart by Country and Year"),
           headerPanel("Title"),
           sidebarPanel(
             p("Adjust the filters in order to see freedom scores for a specific Country in a specific year."),
             selectInput('select_country', 'Select a Country:', choices = unique(allCodes$CountryName), selected = 'United States'),
             selectInput('selected_year', 'Select a Year:', choices = unique(allCodes$Year), selected = 2008),
             h4("Key:"),
             p(strong("ef_legal_military:"), "Legal Military Freedom Score"),
             p(strong("ef_score:"), "Economic Freedom Score"),
             p(strong("hf_score:"), "Human Freedom Score"),
             p(strong("pf_expression:"),"Personal Freedom of Expression Score"),
             p(strong("pf_religion:"), "Personal Freedom of Religion Score"),
             p(strong("pf_score:"), "Personal Freedom Score")
           ),
           mainPanel(
             plotlyOutput('trendPlot')
           )
  ),
  
  tabPanel("Table",
           titlePanel("Interactive Table"),
           headerPanel("Title"),
           sidebarPanel(
             
           ),
           mainPanel(
           )
  ),
  # create tab for HF Map
  navbarMenu("Maps", 
            
  tabPanel("Human Freedom Scores", 
    titlePanel("World Mapping of Freedom Scores 2008-2016"),
    # headerPanel("World Mapping of Freedom Scores 2008-2016"),
    sidebarPanel(
      p("Select a year to see the world mapping of the freedom scores for that year."),
      selectInput('select_year',
                  label = "Select Year",
                  choices = sort(unique(hf_df$Year), decreasing = FALSE),
                  selected = 2008
      )
    ),
    mainPanel(
      plotlyOutput("dynamicHF")
    )
    # h3("Static"),
    # plotlyOutput("staticHF"),
    # h3("Human Freedom Scores By Year"),
    
    # dataTableOutput("datatable")
    # plotlyOutput("dynamicHF")
    # p("This is a summary of the project")
    
  ),
  
  tabPanel("Map By Score",
           titlePanel("Map by Score"),
           headerPanel("Title"),
           sidebarPanel(
             selectInput('select_id', 'Select a Type of Score:', choices = unique(allIDS), selected = "hf_score"),
             selectInput('select_mapyear', 'Select a Year:', choices = unique(all$Year), selected = 2010)
           ),
           mainPanel(
             plotlyOutput("dynamicMapScore")
           ))
  
  )

)


shinyApp(ui = ui, server = server)

