require('crawl'); require('rgdal'); require('RJSONIO')

load('predObj.Rdata')

runNFS <- function() {
  nfs_line <- Line(cbind(nfs_predObj$mu.x,nfs_predObj$mu.y))
  nfs_line <- Lines(list(nfs_line),ID="nfs")
  nfs_line <- SpatialLines(list(nfs_line))
  
  proj4string(nfs_line) <- CRS("+proj=longlat +datum=WGS84 +lon_wrap=180")
  nfs_line <- spTransform(nfs_line,CRS("+proj=longlat +datum=WGS84 +lon_wrap=0"))
  nfs_line <-SpatialLinesDataFrame(nfs_line,data=data.frame(ID="nfs"),match.ID=FALSE)
  
  nfs_obsPoints <- subset(nfs_predObj,locType=="o")
  coordinates(nfs_obsPoints) <- c("longitude","latitude")
  proj4string(nfs_obsPoints) <- CRS("+proj=longlat +datum=WGS84 +lon_wrap=180")
  nfs_obsPoints <- spTransform(nfs_obsPoints,CRS("+proj=longlat +datum=WGS84 +lon_wrap=0"))
  
  if(file.exists('nfs_line.geojson')){
    file.remove('nfs_line.geojson')
  }
  
  if(file.exists('nfs_points.geojson')){
    file.remove('nfs_points.geojson')
  }
  
  writeOGR(nfs_line, 'nfs_line.geojson','nfs', driver='GeoJSON',check_exists=TRUE,overwrite_layer=TRUE)
  writeOGR(nfs_obsPoints, 'nfs_points.geojson','nfs', driver='GeoJSON',check_exists=TRUE,overwrite_layer=TRUE)
  
  json_line <<- RJSONIO::fromJSON('nfs_line.geojson')
  json_points <<- RJSONIO::fromJSON('nfs_points.geojson')
}

runHS <- function() {
  hs_line <- Line(cbind(hs_predObj$mu.x,hs_predObj$mu.y))
  hs_line <- Lines(list(hs_line),ID="hs")
  hs_line <- SpatialLines(list(hs_line))
  
  proj4string(hs_line) <- CRS("+proj=longlat +datum=WGS84 +lon_wrap=180")
  hs_line <- spTransform(hs_line,CRS("+proj=longlat +datum=WGS84 +lon_wrap=0"))
  hs_line <-SpatialLinesDataFrame(hs_line,data=data.frame(ID="hs"),match.ID=FALSE)
  
  hs_obsPoints <- subset(hs_predObj,locType=="o")
  coordinates(hs_obsPoints) <- c("longitude","latitude")
  proj4string(hs_obsPoints) <- CRS("+proj=longlat +datum=WGS84 +lon_wrap=180")
  hs_obsPoints <- spTransform(hs_obsPoints,CRS("+proj=longlat +datum=WGS84 +lon_wrap=0"))
  
  
  if(file.exists('hs_line.geojson')){
    file.remove('hs_line.geojson')
  }
  
  if(file.exists('hs_points.geojson')){
    file.remove('hs_points.geojson')
  }
  
  writeOGR(hs_line, 'hs_line.geojson','hs', driver='GeoJSON',check_exists=TRUE,overwrite_layer=TRUE)
  writeOGR(hs_obsPoints, 'hs_points.geojson','hs', driver='GeoJSON',check_exists=TRUE,overwrite_layer=TRUE)
  json_line <<- RJSONIO::fromJSON('hs_line.geojson')
  json_points <<- RJSONIO::fromJSON('hs_points.geojson')
}
