#' ## START MODULE 2.1 
#' **OBJECTIVE:** Determine characteristics of shapefiles and rasters
#' tested on R versions 3.1.X, 3.2.X

#+ Load packages...
   library(maptools) # fxns: readShapePoly
   library(rgdal)    # fxns: readOGR, spTransform
   library(raster)   # fxns: drawPoly
#+ Some initializations: set working directory/path to data
   path.root <- "~/Documents/Intro-Spatial-R/"
   # path.root <- "~/words/classes/IALE2015_gisRcourse"
   path.mod <- paste(path.root, "module2", sep = "")
   setwd(path.mod)

#' ## Shapefile Data Types
#' #### Import polygon shapefile
#+ Example: Colorado Plateau Boundary
   cp.poly2 <- readOGR(dsn = "data", # dsn="." is current working directory
      layer = "COP_boundpoly_aea") # layer = "shapefile to import"
   cp.poly2  # examine attributes; NOTE has projection (coord.ref)
   class(cp.poly2) # polygon shapefiles are of class => SpatialPolygonsDataFrame in R
##   examine structure; NOTE characteristic called "slots"
   str(cp.poly2)  # examine structure
##   "slots" are where shapefile attributes are carried
##     @ symbol accesses slots, e.g.
   cp.poly2@bbox  # returns the bounding box of the polygon
   cp.poly2@proj4string  # returns the projection (coord. ref)
   coordinates(cp.poly2)  # coordinates of polygon centroid 

#' The Colorado Plateau shapefile has only one data attribute, so we will look at one with more data.

#+ Example: North American States
   states <- readOGR(dsn = "data", layer = "na_states_aea")
##   examine structure !!!! WARNING !!!! voluminous output w/str()
   states  # examine
   str(states)  # examine; NOTE there are 95 states and 95 polygons, 1 for each state
##   shapefile data in dataframe "data" with variables "CODE" and "NAME"
   states@data$CODE  # returns state codes; NOTE $ to access specific variables in the data slot
   states@data$NAME  # returns state names
##   can bypass long call (as below) for class => dataframe elements
   states$CODE  # bad habit based on experience; recommend use long call


#' #### Import point shapefile with attributes
#' shapefiles of points are of class => SpatialPointsDataFrame in R
#+ Example: Cities in the Colorado Plateau
   cp.cities <- readOGR("data", layer = "COP_Major_Cities_pt")
   cp.cities  # examine
   str(cp.cities)  # examine; NOTE @data attributes
##   attribute names in point shapefile
   names(cp.cities)  # returns all attribute names in shapefile
   cp.cities$NAME  # returns cities in CP
   cp.cities$POP2000  # returns 2000 population by city in CP
   cp.cities$POP2007  # returns 2007 population by city in CP
   coordinates(cp.cities)  # returns coordinates of cities


#' #### Import lines shapefile
#' shapefiles of lines are of class => SpatialLinesDataFrame in R
#+ Example: NHD streams and rivers
   cp.hohflow <- readOGR(dsn = "data", layer = "COP_NHD_Flowlines_line")
   cp.hohflow  # examine
   str(cp.hohflow)  # examine; lots of output !!
   names(cp.hohflow)  # all attribute names
## create list of unique names and use to subset rivers
   hohflow.nm <- unique(cp.hohflow$GNIS_Name)  # list of values in column GNIS_Name
   hohflow.rv <- hohflow.nm[grep("River", hohflow.nm)]  # select GNIS_Name w/'River' only
   
   
#' ## Raster (grid) Data
#' #### Import raster (grid) file
#' rasters (grids) of values are of class => RasterLayer in R
#+ Example NDVI values in SW USA
## build raster from ENVI w/.hdr; flat ascii
   ndvi500m.wgs84 <- raster("data/N200530602133CBR_v1.1.dat", format = "ENVI")
   ndvi500m.wgs84  # examine raster attributes; single layer
   names(ndvi500m.wgs84)  # examine raster names
   extent(ndvi500m.wgs84)  # examine raster extent
   dim(ndvi500m.wgs84)  # examine raster dimensions [X,Y] cell Nos.
   ncell(ndvi500m.wgs84)  # examine number of raster cells
   res(ndvi500m.wgs84)  # examine raster resolution
   projection(ndvi500m.wgs84)  # examine raster projection
   ndvi500m.wgs84@crs@projargs  # same projection as above, accessed via slots

#' #### Import raster from mulit-band landsat file; naive call
#' See package => landsat if truly serious about this, but for now ....
#+
   landsat7 <- raster("data/etm-038031-042600-123457.img")
## examine landsat7; NOTE "band" attribute w/values "1 (of  6  bands)"
##   defaulted to importing band=1; other 6 ignored
   landsat7

#' To build a raster from a multi-band file select band of interest w/"band=" option. You must know band sequence, e.g. that band = 6 represents landsat band 7 (PS this example does not have band 6)
#+
   landsat7.1 <- raster("data/etm-038031-042600-123457.img", band = 1)  # blue
   landsat7.2 <- raster("data/etm-038031-042600-123457.img", band = 2)  # green
   landsat7.3 <- raster("data/etm-038031-042600-123457.img", band = 3)  # red
   # examine; NOTE: band= diff for each raster
   landsat7.1
   landsat7.2
   landsat7.3
   names(landsat7.1) <- "blue"  # to assign name to band
   landsat7.1  # examine

#' **END MODULE 2.1**
