suppressMessages(require('crawl'))
suppressMessages(require('rgdal', quietly=TRUE))
suppressMessages(require('RJSONIO', quietly=TRUE))
suppressMessages(require("adehabitatHR", quietly=TRUE))

load('predObj.Rdata')

createSpatialFiles = function(x, outputID){
  if(!inherits(x, "crwPredict")) stop("You must specify a 'crwPredict' object to use 'createSpatialFiles()'!")
  x_line <- Line(cbind(x$mu.x, x$mu.y))
  x_line <- Lines(list(x_line),ID=outputID)
  x_line <- SpatialLines(list(x_line))
  
  proj4string(x_line) <- CRS("+proj=longlat +datum=WGS84 +lon_wrap=180")
  x_line <- spTransform(x_line,CRS("+proj=longlat +datum=WGS84 +lon_wrap=0"))
  x_line <-SpatialLinesDataFrame(x_line,data=data.frame(ID=outputID),match.ID=FALSE)
  
  x_obsPoints <- subset(x,locType=="o")
  coordinates(x_obsPoints) <- c("longitude","latitude")
  proj4string(x_obsPoints) <- CRS("+proj=longlat +datum=WGS84 +lon_wrap=180")
  x_obsPoints <- spTransform(x_obsPoints,CRS("+proj=longlat +datum=WGS84 +lon_wrap=0"))
  
  coordinates(x) = ~mu.x + mu.y
  proj4string(x) <- CRS("+proj=longlat +datum=WGS84 +lon_wrap=180")
  x_ud = kernelUD(as(x, "SpatialPoints"), grid=256)
  x_ud_rings <- rbind(
    spTransform(getverticeshr(x_ud, 75, ida="hr75"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0")),
    spTransform(getverticeshr(x_ud, 50, ida="hr50"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0")),
    spTransform(getverticeshr(x_ud, 10, ida="hr10"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0"))
  )
  
  lnFile = paste(outputID,'_line.geojson',sep="")
  ptsFile = paste(outputID,'_points.geojson',sep="")
  udFile = paste(outputID,'_ud.geojson',sep="")
  
  if(file.exists(lnFile)){
    file.remove(lnFile)
  }
  
  if(file.exists(ptsFile)){
    file.remove(ptsFile)
  }
  
  if(file.exists(udFile)){
    file.remove(udFile)
  }
  
  # sample the observed points to improve performance
  if(nrow(x_obsPoints) >= 250){
      x_obsPoints <- x_obsPoints[sample(x=nrow(x_obsPoints), size=250),]
  }
  
  writeOGR(x_line, lnFile, outputID, driver='GeoJSON')
  writeOGR(x_obsPoints, ptsFile, outputID, driver='GeoJSON')
  writeOGR(x_ud_rings, udFile, outputID, driver='GeoJSON')
  
  json_line <<- RJSONIO::fromJSON(lnFile)
  json_points <<- RJSONIO::fromJSON(ptsFile)
  json_ud <<- RJSONIO::fromJSON(udFile)
  
}

  
  
# }
# 
# runNFS <- function() {
#   nfs_line <- Line(cbind(nfs_predObj$mu.x,nfs_predObj$mu.y))
#   nfs_line <- Lines(list(nfs_line),ID="nfs")
#   nfs_line <- SpatialLines(list(nfs_line))
#   
#   proj4string(nfs_line) <- CRS("+proj=longlat +datum=WGS84 +lon_wrap=180")
#   nfs_line <- spTransform(nfs_line,CRS("+proj=longlat +datum=WGS84 +lon_wrap=0"))
#   nfs_line <-SpatialLinesDataFrame(nfs_line,data=data.frame(ID="nfs"),match.ID=FALSE)
#   
#   nfs_obsPoints <- subset(nfs_predObj,locType=="o")
#   coordinates(nfs_obsPoints) <- c("longitude","latitude")
#   proj4string(nfs_obsPoints) <- CRS("+proj=longlat +datum=WGS84 +lon_wrap=180")
#   nfs_obsPoints <- spTransform(nfs_obsPoints,CRS("+proj=longlat +datum=WGS84 +lon_wrap=0"))
#   
#   nfs_predObj_sp = nfs_predObj
#   coordinates(nfs_predObj_sp) = ~mu.x + mu.y
#   proj4string(nfs_predObj_sp) <- CRS("+proj=longlat +datum=WGS84 +lon_wrap=180")
#   nfs_ud = kernelUD(as(nfs_predObj_sp, "SpatialPoints"), grid=256)
#   nfs_ud <- rbind(
#     spTransform(getverticeshr(nfs_ud, 75, ida="hr75"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0")),
#     spTransform(getverticeshr(nfs_ud, 50, ida="hr50"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0")),
#     spTransform(getverticeshr(nfs_ud, 10, ida="hr10"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0"))
#   )
#   
#   if(file.exists('nfs_line.geojson')){
#     file.remove('nfs_line.geojson')
#   }
#   
#   if(file.exists('nfs_points.geojson')){
#     file.remove('nfs_points.geojson')
#   }
#   
#   if(file.exists('nfs_ud.geojson')){
#     file.remove('nfs_ud.geojson')
#   }
#   
#   
#   writeOGR(nfs_line, 'nfs_line.geojson','nfs', driver='GeoJSON',check_exists=TRUE,overwrite_layer=TRUE)
#   writeOGR(nfs_obsPoints, 'nfs_points.geojson','nfs', driver='GeoJSON',check_exists=TRUE,overwrite_layer=TRUE)
#   writeOGR(nfs_ud, 'nfs_ud.geojson','nfs', driver='GeoJSON',check_exists=TRUE,overwrite_layer=TRUE)
#   
#   json_line <<- RJSONIO::fromJSON('nfs_line.geojson')
#   json_points <<- RJSONIO::fromJSON('nfs_points.geojson')
#   json_ud <<- RJSONIO::fromJSON('nfs_ud.geojson')
#   
# }
# 
# runHS <- function() {
#   hs_line <- Line(cbind(hs_predObj$mu.x,hs_predObj$mu.y))
#   hs_line <- Lines(list(hs_line),ID="hs")
#   hs_line <- SpatialLines(list(hs_line))
#   
#   proj4string(hs_line) <- CRS("+proj=longlat +datum=WGS84 +lon_wrap=180")
#   hs_line <- spTransform(hs_line,CRS("+proj=longlat +datum=WGS84 +lon_wrap=0"))
#   hs_line <-SpatialLinesDataFrame(hs_line,data=data.frame(ID="hs"),match.ID=FALSE)
#   
#   hs_obsPoints <- subset(hs_predObj,locType=="o")
#   coordinates(hs_obsPoints) <- c("longitude","latitude")
#   proj4string(hs_obsPoints) <- CRS("+proj=longlat +datum=WGS84 +lon_wrap=180")
#   hs_obsPoints <- spTransform(hs_obsPoints,CRS("+proj=longlat +datum=WGS84 +lon_wrap=0"))
#   
#   
#   if(file.exists('hs_line.geojson')){
#     file.remove('hs_line.geojson')
#   }
#   
#   if(file.exists('hs_points.geojson')){
#     file.remove('hs_points.geojson')
#   }
#   
#   writeOGR(hs_line, 'hs_line.geojson','hs', driver='GeoJSON',check_exists=TRUE,overwrite_layer=TRUE)
#   writeOGR(hs_obsPoints, 'hs_points.geojson','hs', driver='GeoJSON',check_exists=TRUE,overwrite_layer=TRUE)
#   json_line <<- RJSONIO::fromJSON('hs_line.geojson')
#   json_points <<- RJSONIO::fromJSON('hs_points.geojson')
# }
