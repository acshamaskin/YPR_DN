library(shiny)
source('global.R',local=T)
shinyUI(fluidPage(
  titlePanel("Yield Per Recruit"),
  
  sidebarLayout(
    sidebarPanel( 
      h3("Parameter Estimates"),
      h6("k is back calculated from Linf"),
      fluidRow(
        column(5,
               checkboxGroupInput("b","W-L Slope:", 
                                  c("High"=3,"Medium"=2,"Low"=1), selected=2)),
        column(5,
               checkboxGroupInput("Linf", "Linf:",
                                  c("High"=3,"Medium"=2,"Low"=1), selected=2)),
        column(5,
               checkboxGroupInput("A", "Annual Mortality:",
                                  c("High"=3,"Medium"=2,"Low"=1), selected=2)),
        column(5,
               checkboxGroupInput("up", "Exploitation(proportion of A):", 
                                  c("High"=3,"Medium"=2,"Low"=1), selected=2))
              
      ),
      h4("System-wide Settings"),
      fluidRow(
        column(3,
               textInput("quality",
                         label =h6("big fish length (in.)"), value="12")),
        column(4,
               textInput("mll",
                         label =h6("Length Limit (Inches)"), value = "9,10,11"))
        
      ),
      h4("Utilities (each between 0-100)"),
      fluidRow(
        column(4,
               sliderInput("Yieldweight",
                           label=h6("Yield:"), min = 0, max = 100, value= 25, round = 0)),
 
        column(4,
               sliderInput("AvgWtweight",
                           label=h6("Average Weight:"), min = 0, max = 100, value= 25, round = 0))
      ),
      fluidRow(
        column(4,
               sliderInput("Hrateweight",
                           label=h6("Harvest Rate:"), min = 0, max = 100, value= 25, round = 0)),
      
        column(4,
               sliderInput("QHrateweight",
                           label=h6("Big Fish Harvest:"), min = 0, max = 100, value= 25, round = 0))
      
      )),
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Length-Limit Scores", 
                           br(),
                           tableOutput("ScoreLL"),
                           br()),
                  tabPanel("Plot",
                           fluidRow(
                           column(4,
                                  radioButtons("datt","Data Type:",
                                               c("Yield" = "Yield",
                                                 "Average Wt." = "AverageWt",
                                                 "Harvest Rate" = "HarvestRate",
                                                 "Quality Harvest" = "QualityHarvest"))),
                          # column(4,
                          #        textOutput("llinput"))
                           column(4,
                                  radioButtons("llselect","Length Limit (inches):",
                                              choices = c("llinput()[[1]]",
                                                        "llinput()[[2]]","llinput()[[3]]",
                                                        "showall"= "Show All")))
                           ),
                                  br(),  
                          textOutput("text1"),
                                  plotOutput("plot", height = 350)
                  )
                  
                  )))
  ))
