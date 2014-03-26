
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

require(shiny)
require(rCharts)
require(crawl)

shinyServer(function(input, output) {
 
  output$ocean_map <- renderMap({
    ocean_map <- Leaflet$new()
    ocean_map$tileLayer('https://services.arcgisonline.com/ArcGIS/rest/services/Ocean/World_Ocean_Base/MapServer/tile/{z}/{y}/{x}')
    ocean_map$params$layerOpts$attribution = 'ESRI World Ocean Base (Sources: Esri, GEBCO, NOAA, National Geographic, DeLorme, HERE, Geonames.org, and other contributors)'
    ocean_map$set(height = 500, width = "100%")
    ocean_map$setView(c(55, -165), 3) #TODO: set extent dynamically based on data
    
    if(input$example == "Northern Fur Seal"){
      createSpatialFiles(nfs_predObj, "nfs")
      cat("creating/updating spatial files for nfs\n",file=stderr())
    } else if (input$example == "Harbor Seal") {
      createSpatialFiles(hs_predObj, "hs")
      cat("creating/updating spatial files for hs\n",file=stderr())
    }
    
    if(input$example %in% c("Northern Fur Seal", "Harbor Seal")){
      # determine which layers are checked
     if(input$kernel & !input$lines & !input$points) {
       json_layers <- list(json_ud)
     } else if(!input$kernel & input$lines & !input$points) {
       json_layers <- list(json_line)
     } else if(!input$kernel & !input$lines & input$points) {
       json_layers <- list(json_points)
     } else if(input$kernel & input$lines & !input$points) {
       json_layers <- list(json_ud,json_line)
     } else if(input$kernel & !input$lines & input$points) {
       json_layers <- list(json_ud,json_points)
     } else if(!input$kernel & input$lines & input$points) {
       json_layers <- list(json_line,json_points)
     } else if(input$kernel & input$lines & input$points) {
       json_layers <- list(json_ud,json_line,json_points)
     } else json_layers <- list(" ")
     
     ocean_map$geoJson(json_layers,
                       style = "#! function(feature) {
                                var hr2col = {'hr90':'#f7fcfd',
                                              'hr80':'#e0ecf4',
                                              'hr70':'#bfd3e6',
                                              'hr60':'#9ebcda',
                                              'hr50':'#8c96c6',
                                              'hr40':'#8c6bb1',
                                              'hr30':'#88419d',
                                              'hr20':'#810f7c',
                                              'hr10':'#4d004b'};
                                if ( feature.geometry.type === 'MultiPolygon' ) {
                                return{color: hr2col[feature.properties['id']], 
                                        fillOpacity: 0.3, weight: 0};
                                }
                                if ( feature.geometry.type === 'LineString' ) {
                                return{color: '#ff7f00', weight: 2};
                                }
                       }
                                !#",
                        pointToLayer =  "#! function(feature, latlng){
                                             return L.circleMarker(latlng, {
                                             radius: 2,    
                                             color: '#4daf4a',
                                             weight: 0,
                                             fillOpacity: 0.5
                                             })
                                             } !#"
                       )
    }
    cat("updating map with data\n",file=stderr())
    return(ocean_map)
  })
  
  output$banner_image <- renderImage({
    filename <- normalizePath(file.path('banner.png'))
    
    list(src = filename,
         alt = paste("NOAA Fisheries Banner"))
    
  }, deleteFile = FALSE)
  
})
