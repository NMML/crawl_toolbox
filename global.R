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
    spTransform(getverticeshr(x_ud, 90, ida="hr90"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0")),
    spTransform(getverticeshr(x_ud, 80, ida="hr80"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0")),
    spTransform(getverticeshr(x_ud, 70, ida="hr70"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0")),
    spTransform(getverticeshr(x_ud, 60, ida="hr60"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0")),
    spTransform(getverticeshr(x_ud, 50, ida="hr50"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0")),
    spTransform(getverticeshr(x_ud, 40, ida="hr40"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0")),
    spTransform(getverticeshr(x_ud, 30, ida="hr30"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0")),
    spTransform(getverticeshr(x_ud, 20, ida="hr20"), CRS("+proj=longlat +datum=WGS84 +lon_wrap=0")),
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
