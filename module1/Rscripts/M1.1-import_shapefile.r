######## START MODULE 1.1 ########
#### OBJECTIVE:  
####   Import an ARC shapefile of desired projection
####
#### tested on R versions 3.1.X, 3.2.X

## some needed libraries
   library(maptools)  # fxns: readShapePoly
   library(rgdal)     # fxns: readOGR, spTransform
   library(raster)    # fxns: drawPoly, drawExtent, projection
   library(sp)        # fxns: SpatialPolygons
## some initializations
   path.root <- "~/IALE2015_gisRcourse"
   path.dat <- paste(path.root, "/data", sep = "")
   setwd(path.dat)  # path for all data in Module1
## some projections as objects for use here and in other Modules
##   projections discussed in greater detail in Module 2.5
##   !!!! WARNING !!!! No hard returns allowed in projection string assignment; R won't like you
   prj.aea <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"  # aea NAD83 projection
   prj.wgs84 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"  # wgs84 projection

## import ARC shapefile; EXAMPLE Colorado Plateau (CP) boundary in Albers
##   fxn readShapePoly => package maptools
   cp.poly1 <- readShapePoly("COP_boundpoly_aea")  # naive call; coordinates imply projection type
   cp.poly1  # examine attributes; NOTE no projection (coord. ref) assignment 
   plot(cp.poly1)  # examine as plot
## import w/projection assignment
   cp.poly <- readShapePoly("COP_boundpoly_wgs84", proj4string = CRS(prj.wgs84))
   cp.poly  # examine attributes; NOTE projection assigned now
   plot(cp.poly)  # examine as plot

## CANNOT use readShapePoly to import shapefile and change projection during import
##   example imports AEA and tries to change to WGS84
##   NOTE Error returned; input coordinates will not match desired output coordinates
   cp.poly2 <- readShapePoly("COP_boundpoly_aea", proj4string = CRS(prj.wgs84))
## to change projection of shapefile during import use package rgdal
##   use fxns [readOGR, spTransform] from package => rgdal
## import shapefile w/AEA projection
   cp.poly3 <- readOGR(dsn = ".", layer = "COP_boundpoly_aea")  # dsn='.' is cur dir, layer='shapefile to import'
## change import projection (AEA) to desired projection (WGS84)
   cp.poly4 <- spTransform(cp.poly3, CRS = CRS(prj.wgs84))
## NOT RUN; hard code alternative to above; 
   #cp.poly4 <- spTransform(cp.poly3, CRS = CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0'))
   cp.poly3  # examine; AEA projection of original shapefile
   cp.poly4  # examine; WGS84 projection of new shapefile
## some simple plots; NOTE orientation diffs of WGS84 vs. AEA
   par(mfrow = c(1, 2))
   plot(cp.poly4, main = "WGS84")
   plot(cp.poly1, main = "AEA")
   par(mfrow = c(1, 1))
## save output; used in other GIS vignettes
   #save(cp.poly, file = "outdata/GIS01.RData")

## import shapefiles in .zip format from internet site
## ASSUME in browser go to:  http://gis.utah.gov/data/geoscience/soil/
##   click "Download Dataset"
##   right click "shp.zip" file
##   click "Copy Link Location"
##   paste below and assign to object (url.zip) as in:
   url.zip <- "ftp://ftp.agrc.utah.gov/UtahSGID_Vector/UTM12_NAD83/GEOSCIENCE/UnpackagedData/Soils/_Statewide/Soils_shp.zip"
   tmp.dir <- tempdir()
   tmp.dir  # write tmp dir; disappears after quitting R (this is good)
   tmp.file <- tempfile(tmpdir = tmp.dir, fileext = ".zip")
   tmp.file  # ditto
   download.file(url.zip, tmp.file)  # download from source into tmp.dir
## examine files before unzip
   f.name <- unzip(tmp.file, list = T)$Name
   f.name  # list of all files in .zip file
   grep(".shp", unzip(tmp.file, list = T)$Name, value = T)  # code lists ALL files w/.shp
   grep(".shp$", unzip(tmp.file, list = T)$Name, value = T)  # code lists file ending w/.shp ONLY; NOTE $ symbol
## unzip to default or specified dir
   setwd(path.dat)  # if needed
   unzip(tmp.file)  # unzips to current dir; NOTE will be in Soils dir
   shp.in <- grep(".shp$", unzip(tmp.file, list = T)$Name, value = T)  # assign shp file to import
   ut.soil <- readShapePoly(shp.in)  # be patient ....
   ut.soil  # examine
   #plot(ut.soil) # NOT RUN
## NOT RUN; alternative input code 
##   !!!! WARNING !!!! dangerous if >1 shape file
   #ut.soil <- readShapePoly(grep('.shp$', unzip(tf,list = T)$Name, value = T)) # dangerous if >1 .shp file

## build an irregular polygon interactively
   plot(cp.poly)  # plot where new polygon to be constructed
## move mouse into plot, click, move to next location, click, etc, until close polygon
##   to STOP polygon build, right click, then Stop
##   NOTE:  fxn will automatically close out polygon; just do final click near start point
   poly1 <- drawPoly()
   poly1  # examine; NOTE no projection
   #drawLine() # NOT RUN; same process as drawPoly but for drawing a line assign projection
   projection(poly1) <- projection(cp.poly)
## some plots
   plot(cp.poly)
   plot(poly1, add = T, col = "red")
   
## build an rectangular polygon interactively
   plot(cp.poly)  # plot where new polygon to be constructed 
## move mouse into plot, click for upper left location
##   move mouse to lower right location, click
   rect1 <- drawExtent()
   rect1  # examine; NOTE only an extent
## to convert extent to polygon
   rect2 <- as(rect1, "SpatialPolygons")  # coerce to SpatialPolygons
   projection(rect2) <- projection(cp.poly)  # assign desired projection
## some plots
  plot(cp.poly)
  plot(rect2, add = T, col = "red")
####
######## END MODULE 1.1 ######## 




