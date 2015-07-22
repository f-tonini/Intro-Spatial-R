######## START MODULE #2.1 ########
#### OBJECTIVE:  
####   Determine characteristics of shapefiles and rasters
####
#### tested on R versions 3.1.X, 3.2.X

## some libraries ...
   library(maptools) # fxns: readShapePoly
   library(rgdal)    # fxns: readOGR, spTransform
   library(raster)   # fxns: drawPoly
## some initializations ...
   #path.root <- "~/IALE2015_gisRcourse"
   path.root <- "~/words/classes/IALE2015_gisRcourse"
   path.dat <- paste(path.root, "/data", sep = "")
   setwd(path.dat)


#### polygon data
## import polygon shapefile w/out attributes; EXAMPLE Colorado Plateau (CP) boundary in Albers
## shapefiles of polygons are of class => SpatialPolygonsDataFrame in R
##   fxn readShapePoly
   cp.poly1 <- readShapePoly("COP_boundpoly_aea")  # naive call; coordinates imply projection type
   cp.poly1  # examine attributes; NOTE no projection (coord. ref) assignment 

## import polygon shapefile w/out attributes; EXAMPLE Colorado Plateau (CP) boundary in Albers
##   fxn readOGR
   cp.poly2 <- readOGR(dsn = ".", layer = "COP_boundpoly_aea") # dsn="." is cur dir, layer="shapefile to import"
   cp.poly2  # examine attributes; NOTE has projection (coord.ref)
##   examine structure; NOTE characteristic called "slots"
   str(cp.poly2)  # examine structure
##   "slots" are where shapefile attributes are carried
##     @ symbol access slots, eg cp.poly@bbox
   cp.poly2@bbox  # returns the bounding box of the polygon
   cp.poly2@proj4string  # returns the projection (coord. ref)
   coordinates(cp.poly2)  # coordinate centroid of polygon

## import point shapefile w/attributes; EXAMPLE N American States
## shapefiles of polygons are of class => SpatialPolygonsDataFrame in R
##   fxn readOGR
   states <- readOGR(dsn = ".", layer = "na_states_aea")
##   examine structure !!!! WARNING !!!! voluminous output w/str()
   states  # examine
   str(states)  # examine; NOTE there are 95 states and 95 polygons, 1 for each state
##   shapefile data in dataframe "data" with variables "CODE" and "NAME"
   states@data$CODE  # returns state codes; NOTE $ to access specific variables
   states@data$NAME  # returns state codes; NOTE $ to access specific variables
##   can bypass long call (as below) for class => dataframe elements
   states$CODE  # bad habit based on experience; recommend use long call
####

#### point data
## import point shapefile w/attributes; EXAMPLE cities in the Colorado Plateau
## shapefiles of points are of class => SpatialPointsDataFrame in R
##   fxn readOGR
   cp.cities <- readOGR(".", layer = "COP_Major_Cities_pt")
   cp.cities  # examine
   str(cp.cities)  # examine; NOTE @data attributes
##   attribute names in point shapefile
   names(cp.cities)  # returns all attribute names in shapefile
   cp.cities$NAME  # returns cities in CP
   cp.cities$POP2000  # returns 2000 population by city in CP
   cp.cities$POP2007  # returns 2007 population by city in CP
   coordinates(cp.cities)  # returns coordinates of cities
####

#### line data  
## import lines shapefile; EXAMPLE NHD streams and rivers
## shapefiles of lines are of class => SpatialLinesDataFrame in R
   cp.hohflow <- readOGR(dsn = ".", layer = "COP_NHD_Flowlines_line")
   cp.hohflow  # examine
   str(cp.hohflow)  # examine; lots of output !!
   names(cp.hohflow)  # all attribute names
## create list of unique names and use to subset rivers
   hohflow.nm <- unique(cp.hohflow$GNIS_Name)  # list of values in column GNIS_Name
   hohflow.rv <- hohflow.nm[grep("River", hohflow.nm)]  # select GNIS_Name w/'River' only
####   
   
#### raster (grid) data
## import raster (grid) file; EXAMPLE NDVI values SW USA
## rasters (grids) of values are of class => RasterLayer in R
## build raster from ENVI w/.hdr; flat ascii
   ndvi500m.wgs84 <- raster("N200530602133CBR_v1.1.dat", format = "ENVI")
   ndvi500m.wgs84  # examine raster attributes; single layer
   names(ndvi500m.wgs84)  # examine raster names
   extent(ndvi500m.wgs84)  # examine raster extent
   dim(ndvi500m.wgs84)  # examine raster {X,Y] cell Nos.
   ncell(ndvi500m.wgs84)  # examine raster No. cells
   res(ndvi500m.wgs84)  # examine raster resolution
   projection(ndvi500m.wgs84)  # examine raster projection
   ndvi500m.wgs84@crs@projargs  # same projection as above; access via slots

## import raster from mulit-band landsat file; naive call
##   see package => landsat if truly serious about this, but for now ....
   landsat7 <- raster("etm-038031-042600-123457.img")
## examine landsat7; NOTE "band" attribute w/values "1 (of  6  bands)"
##   defaulted to importing band=1; other 6 ignored
   landsat7
## build raster from multi-band file; select band of interest w/"band=" option
##   you must know band sequence, eg that band=6 represents landsat band 7
##   (PS this ex. does not have band 6)
   landsat7.1 <- raster("etm-038031-042600-123457.img", band = 1)  # blue
   landsat7.2 <- raster("etm-038031-042600-123457.img", band = 2)  # green
   landsat7.3 <- raster("etm-038031-042600-123457.img", band = 3)  # red
   landsat7.1
   landsat7.2
   landsat7.3  # examine; NOTE: band= diff for each raster
   names(landsat7.1) <- "blue"  # to assign name to band
   landsat7.1  # examine
####
######## END MODULE 2.1 ########
