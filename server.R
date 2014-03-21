
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

require(shiny); require(rCharts); require(crawl)

shinyServer(function(input, output) {
 
  output$ocean_map <- renderMap({
    if(input$example == "northernFurSeal"){
      runNFS()
    } else if (input$example == "harborSeal") {
      runHS()
    }
    ocean_map <- Leaflet$new()
    ocean_map$tileLayer('http://services.arcgisonline.com/ArcGIS/rest/services/Ocean/World_Ocean_Base/MapServer/tile/{z}/{y}/{x}')
    ocean_map$params$layerOpts$attribution = 'ESRI World Ocean Base'
    ocean_map$set(height = 500, width = "100%")
    ocean_map$setView(c(55, -165), 3)
    ocean_map$geoJson(json_ud)
#     ocean_map$geoJson(json_line)
#     ocean_map$geoJson(json_points,
#       pointToLayer =  "#! function(feature, latlng){
#         return L.circleMarker(latlng, {
#           radius: 2,
#           fillColor: feature.properties.fillColor || 'black',    
#           color: '#000',
#           weight: 0,
#           fillOpacity: 0.5
#         })
#     } !#")

    return(ocean_map)
  })
  
  output$banner_image <- renderImage({
    # When input$n is 3, filename is ./images/image3.jpeg
    filename <- normalizePath(file.path('banner.png'))
    
    # Return a list containing the filename and alt text
    list(src = filename,
         alt = paste("NOAA Fisheries Banner"))
    
  }, deleteFile = FALSE)
  
})
