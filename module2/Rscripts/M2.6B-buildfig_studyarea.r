######## START MODULE 2.6B ########
#### OBJECTIVE:  
####   Build a study area map with polygons, lines, & point shapefile input
####   Add a raster background
####
#### No data objects are required for this module
####
#### Tested on R versions 3.1.X, 3.2.X


## some needed libraries
   library(rgdal)     # fxns: readOGR, writeOGR
   library(raster)    # fxns: crop, hillShade
## some initializations
   #path.root <- "~/IALE2015_gisRcourse"
   path.root <- "~/words/classes/IALE2015_gisRcourse"
   path.dat <- paste(path.root, "/data", sep = "")
   setwd(path.dat)

## some initialization
##   import shapefiles to be used in study area graph 
##   CP study area
   cp.region <- readOGR(dsn = ".", layer = "COP_boundpoly_wgs84")
##   north american states/provinces for USA, Canada, Mexico
   states <- readOGR(dsn = ".", layer = "na_states_wgs")
##   subset states UT, AZ, CO, NM
##     NOTE: str() to determine shapefile attributes; str@data is attributes
##       here, states$CODE returns all state-based codes
##     NOTE: rgdal squirrelly; must exclude NA or crashes if NA present
   states$CODE  # state codes
   cp.states <- states[states$CODE == "UT" & !is.na(states$CODE) | 
                       states$CODE == "CO" & !is.na(states$CODE) | 
                       states$CODE == "NM" & !is.na(states$CODE) | 
	                   states$CODE == "AZ" & !is.na(states$CODE), ]
## NOT RUN; write out subset polygon into ESRI format if desired
   #writeOGR(cp.states, dsn = ".", layer = "cp.states", morphToESRI = T, driver = "ESRI Shapefile")

## import some [x.y] data; here pres-abs of Juniperus osteosperma (juos)
   juos1 <- read.csv("juos_presab.csv", header = T)
   str(juos1)  # examine; NOTE wgs84 projection for [x,y] based on variable names
   head(juos1)  # examine

#### START plot #1: presence absence points w/no background
## plot study area w/states cropped to extent of study region
   plot(crop(cp.states, cp.region), col = "grey95", main = "Merry Christmas!!")

## different colors for points meeting different conditions
   points(juos1$wgs84_x[juos1$juos == 0], juos1$wgs84_y[juos1$juos == 0], col = "red", pch = 20)
   points(juos1$wgs84_x[juos1$juos == 1], juos1$wgs84_y[juos1$juos == 1], col = "darkgreen", pch = 20)

## legend call to mix line & dot symbols; NOTE -1 indicates a "blank" value
   legend("topleft", legend = c("Absence", "Presence"), cex = 1.25, bty = "n", 
          inset = 0.04, pch = c(20, 20), pt.cex = 1.75, col = c("red", "darkgreen"))

## save plot if desired; pdf your best bet format
   #savePlot(filename = "outdata/juosPA.pdf", type = "pdf")
#### END plot #1

#### START plot #2: presence absence points on shaded elevation
## import elev raster
   cp.elev <- crop(raster("elev_1k_wgs.img"), cp.region)
## make color ramp of 10 bins of grey
   elev.shade <- colorRampPalette(c("grey100", "grey0"))(10)
## plot elev raster
   plot(cp.elev, col = elev.shade, legend = F, 
     main = expression(italic(J.)*" "*italic(osteosperma)*" in the Colorado Plateau"),
     ylab = "Latitude", xlab = "Longitude")
## different colors for points meeting different conditions
   points(juos1$wgs84_x[juos1$juos == 0], juos1$wgs84_y[juos1$juos == 0], 
     col = "red", pch = 20, cex = 0.75)
   points(juos1$wgs84_x[juos1$juos == 1], juos1$wgs84_y[juos1$juos == 1], 
     col = "darkgreen", pch = 20, cex = 0.75)
## add CP boundary
   plot(cp.region, add = T, lwd = 2)
## add state boundaries cropped to CP
   plot(crop(cp.states, cp.region), add = T)
## add legend to plot
   legend("topleft", legend = c("Absence", "Presence"), cex = .75, bg="white", title = "JUOS Presence/Absence",
     inset = c(0.02, 0.075), pch = c(20, 20), pt.cex = 1.75, col = c("red", "darkgreen"))
#### END plot #2

######## END Module 2.6 ########





 
