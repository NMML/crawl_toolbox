require('crawl'); require('rgdal'); require('RJSONIO')

#load example data from crawl
data(northernFurSeal)

argosClasses <- c("3", "2", "1", "0", "A", "B")
ArgosMultFactors <- data.frame(Argos_loc_class=argosClasses,
                               errX=log(c(1, 1.5, 4, 14, 5.21, 20.78)),
                               errY=log(c(1, 1.5, 4, 14, 11.08, 31.03)))
nfsNew <- merge(northernFurSeal, ArgosMultFactors,
                by=c("Argos_loc_class"), all.x=TRUE)
nfsNew <- nfsNew[order(nfsNew$Time), ]

# State starting values
initial.drift <- list(a1.x=c(189.686, 0, 0), a1.y=c(57.145, 0, 0),
                      P1.x=diag(c(0, 0.001, 0.001)),
                      P1.y=diag(c(0, 0.001, 0.001)))

##Fit random drift model
# Check out the parameters 
displayPar(mov.model=~1, err.model=list(x=~errX, y=~errY), drift.model=TRUE,
           data=nfsNew, fixPar=c(NA, 1, NA, 1, NA, NA, NA, NA))

fit <- crwMLE(mov.model=~1, err.model=list(x=~errX, y=~errY), drift.model=TRUE,
              data=nfsNew, coord=c("longitude", "latitude"), polar.coord=TRUE,
              Time.name="Time", initial.state=initial.drift, 
              fixPar=c(NA, 1, NA, 1, NA, NA, NA, NA), 
              control=list(maxit=2000),
              initialSANN=list(maxit=300)
)

##Make hourly location predictions
nfs_predTime <- seq(ceiling(min(nfsNew$Time)), floor(max(nfsNew$Time)), 1)
nfs_predObj <- crwPredict(object.crwFit=fit, nfs_predTime, speedEst=TRUE, flat=TRUE)

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

nfs_json_line <- RJSONIO::fromJSON('nfs_line.geojson')
nfs_json_points <- RJSONIO::fromJSON('nfs_points.geojson')
