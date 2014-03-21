
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

require(shiny); require(rCharts)

shinyUI(fluidPage(theme = "cerulean/bootstrap.css",
      
      title = "Crawl Telemetry Prediction Toolbox",

      showOutput('ocean_map', 'leaflet'),
      
      fluidRow(
        column(4,
               br(),
               "Welcome to the NOAA Fisheries Marine Animal Telemetry Prediction Toolbox.
                This toolbox depends upon the R-package crawl developed by Devin Johnson
                at the Alaska Fisheries Science Center's National Marine Mammal Laboratory",
               br(),br(),
                "After successfully modeling your animal movement dataset with crawl,
                this toolbox will help you explore the movement and identify important
                areas of use."),
        column(7,offset=1,
               h3("Marine Animal Telemetry Prediction Toolbox"),
               fluidRow(
                  column(6,
                        selectInput("example", "Choose an Example:", 
                        choices = c("northernFurSeal", "harborSeal"))
                        ),
                  column(4,
                         helpText("select from two example datasets included in crawl."))
                  )
        )
      )
  )
)
