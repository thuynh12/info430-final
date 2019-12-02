library(shiny)
library(odbc)
library(DBI)
library(dplyr)
library(RJDBC)
library(plotly)
library(rsconnect)
library(shinythemes)

# retrieve server variable and plot information
source("source.r")


# Define UI for app that draws a histogram ----
ui <- navbarPage(theme = shinytheme("flatly"), "INFO 430",
  
  tabPanel("Summary", 
      titlePanel(h1("Global Freedom Scores")),
      mainPanel(
      h2("Problem Statement"),
      p("It is uncommon for news outlets in the United States to discuss events occurring 
        in different parts of the world. After conducting a global survey, the Pew Research   
        Center discovered that the global median said \"they follow news about their country
        (86%) or city and town (78%) closely,compared with fewer than six-in-ten who say the  
        same when it comes to news about other countries generally (57%)\". This presents a  
        problem because it forms a demographic that becomes ignorant to world events that   
        have the potential to impact their country. Without the ability to make informed  
        decisions, citizens are unable to acquire the knowledge necessary to determine who  
        to vote for in elections and do not understand what is occuring in the rest of the world."),
      h2("Where is this data coming from?"),
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
      h2("Understanding the values"), 
      p("On a scale of 0 to 10, where 10 represents more freedom, the average human freedom rating for 162 
        countries in 2016 was 6.89."),
      h4(strong("Human Freedom Score (hf_score):")), 
      p("Human freedom is a social concept that recognizes the dignity of individuals and is 
        defined here as negative liberty or the absence of coercive constraint."),
      h4(strong("Personal Freedom Score (pf_score):")), 
      p("Personal freedom encompasses the freedom of a person in going and coming, equality before 
        the courts, security of private property, freedom of opinion and its expression, and freedom  
        of conscience subject to the rights of others and of the public"),
      h4(strong("Econmic Freedom Score (ef_score):")), 
      p("Economic freedom is the fundamental right of every human to control his or her own labor and property. 
        In an economically free society, individuals are free to work, produce, consume, and invest in any way they please."),
      h4(strong("Legal Military Freedom Score (ef_legal_military):")), 
      p("A measure of the military’s involvement in politics. Since the military is not elected, involvement, even at a 
peripheral level, diminishes democratic accountability. Military involvement might stem from an external or internal threat, be symptomatic of  
        underlying difficulties, or be a full-scale military takeover."),
      h4(strong("Personal Freedom of Expression Score (pf_expression):")), 
      p("Freedom of speech is a principle that supports the freedom of an individual or a community to articulate their opinions and ideas without fear of retaliation,
censorship, or legal sanction. The term \"freedom of expression\" is sometimes used synonymously but includes any act of seeking, receiving, and imparting information or ideas, regardless of the medium used."),
      h4(strong("Personal Freedom of Religion Score (pf_religion):")), 
      p("Freedom of Religion is the right to practice one's religion or exercise one's beliefs without intervention by the government and to be free of the exercise of authority by a church through the government"),
      h2("What are we trying to do?"),
      p("The main goal of our project is to spread awareness and educate people about 
        the level of freedoms around the world this data alone will be sufficient for analysis,   
        visualization, and documentation. Because of the nature of our topic and data we will   
        not be taking user-submitted data."),
      p(strong("Created by Andrea Koozer, Rahma Kamel and Tracy Huynh"))
      )
      
  ),               
     
  # create tab for scatter plot with personal/economic freedom
  tabPanel("Personal vs. Economic vs. Human", 
      titlePanel("Personal and Economic Freedom"),
      sidebarPanel(position = 'left',
                   p("This scatter plot explores the relationship between personal freedom scores, economic 
                      freedom scores and human freedom scores. The plot contains scores from all countries
                     for years 2008 - 2016. The scatter plot shows that both personal and economic scores 
                     have a positive coorelation with human freedom scores. This means that the human freedom 
                     score increases when economic and personal freedom scores increase.")),
      mainPanel(
      p(""),
      plotlyOutput("scatterPlot1")
      )     
  ), 
  
  # create placeholder tab
  tabPanel("Comparasion of Scores by Country and Year",
           titlePanel("Comparison of Scores By Country and Year"),
           sidebarPanel(
             p("Adjust the filters in order to see freedom scores for a specific Country in a specific year."),
             selectInput('select_country', 'Select a Country:', choices = unique(allCodes$CountryName), selected = 'United States'),
             selectInput('selected_year', 'Select a Year:', choices = sort(unique(allCodes$Year), decreasing = FALSE), selected = 2008),
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
  
  tabPanel("Global Human Freedom Ranking",
           titlePanel("Ranking Country by Human Freedom"),
           # headerPanel("Ranking Country by Human Freedom"),
           sidebarPanel(
             p("Select a year to see the ranking for that year."),
             selectInput('select_tbyear', 'Select a Year:', choices = sort(unique(all$Year), decreasing = FALSE), selected = 2008),
             # plotlyOutput('dynamicTableUnranked'),
             ),
           mainPanel(
             plotlyOutput('dynamicTable'),
             h3("The following are countries that are not ranked:"),
             plotlyOutput('dynamicTableUnranked')
           )
  ),
  # create tab for HF Map
  navbarMenu("Mappings", 
            
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
  ),
  
  tabPanel("All Freedom Scores and Year",
           titlePanel("Mapping Different Scores"),
           sidebarPanel(
             p("Select a year and a score to display the map of that score."),
             selectInput('select_id', 'Select a Type of Score:', choices = sort(unique(allIDS), decreasing = FALSE), selected = "hf_score"),
             selectInput('select_mapyear', 'Select a Year:', choices = unique(all$Year), selected = 2008),
             h4("Key:"),
             p(strong("ef_legal_military:"), "Legal Military Freedom Score"),
             p(strong("ef_score:"), "Economic Freedom Score"),
             p(strong("hf_score:"), "Human Freedom Score"),
             p(strong("pf_expression:"),"Personal Freedom of Expression Score"),
             p(strong("pf_religion:"), "Personal Freedom of Religion Score"),
             p(strong("pf_score:"), "Personal Freedom Score")
           ),
           mainPanel(
             plotlyOutput("dynamicMapScore")
           ))
  
  )

)


shinyApp(ui = ui, server = server)

