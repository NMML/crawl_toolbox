suppressMessages(require(shiny))
suppressMessages(require(rCharts))

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
                areas of use ... eventually. For now, this represents a proof of concept
                and relies on the two example datasets that ship with crawl."),
        column(7,offset=1,
               h3("Marine Animal Telemetry Prediction Toolbox"),
               fluidRow(
                  column(6,
                        selectInput("example", "Choose an Example:", 
                        choices = c("", "Northern Fur Seal", "Harbor Seal"))
                        )
                  ),
               fluidRow(
                 column(6,
                        checkboxInput("lines", "Show tracklines", FALSE),
                        checkboxInput("kernel","Show kernel range",TRUE),
                        checkboxInput("points","Show observed points",FALSE))
                 )
        )
      ),
      fluidRow(
        br(),
        column(6,offset=5,
                      conditionalPanel(
                        condition = "input.points == true",
                        "* points will be sampled to 250 or less for display only"
                      )))
  )
)
