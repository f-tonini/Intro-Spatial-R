######## START MODULE 2.2 ########
#### OBJECTIVE:  
####   Ensures all polygon layers are of same extent & projection
####   Processes for converting polygons to rasters of same dimension, resolution
####     as a "base" raster
####
#### Requires data objects from module #1 (module1.RData) & module #2.1 (module2.1.RData)
####
#### tested on R versions 3.1.X, 3.2.X

## some libraries ...
   library(raster)    # fxns: raster, projectRaster, rasterize, brick, stack
   library(rgdal)     # fxns: readOGR, spTransform
   library(maptools)  # fxns: readShapePoly
## some initializations ...
   #path.root <- "~/IALE2015_gisRcourse"
   path.dat="E:/IALE2015_gisRcourse/data"
   #path.root <- "~/words/classes/IALE2015_gisRcourse"
   path.dat <- paste(path.root, "/data", sep = "")
   setwd(path.dat)
## some projections as objects ...
## one source for projections:
##   http://spatialreference.org/ ; EXAMPLE access as shown in next line
##     Home => Search => EX: "NAD83 Albers" => Click "AlbersNorthAmerican" => Click "Proj4js format"
##     returns projection string; copy & paste string, including quotes as below
## NOTE:  No hard returns allowed in projection string assignment; R won't like you
   prj.aea <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"
   prj.wgs84 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"
## some input GIS layers & characteristics from previous modules ...
   load("outdata/module1.RData")  # some shapefiles & rasters from module #2.1
   ls()  # examine

####
## import a shapefile; fxn => readShapePOly
   states1 <- readShapePoly("na_states_wgs")  # naive call
   states1  # examine; NOTE no projection (coord.ref); coordinates imply projection type
## import a shapefile & assign projection during import
##   NOTE: fxn readShapePoly assumes you know projection 
   states2 <- readShapePoly("na_states_wgs", proj4string = CRS(prj.wgs84))
   states2  # examine; NOTE projection (coord.ref) now assigned
## import and change projection during import
   states3 <- readShapePoly("na_states_wgs", proj4string = CRS(prj.aea))
   states3  # examine; NOTE change in projection (ccord.ref)

## import a shapefile; fxn => readOGR
##   NOTE: dsn='.' is cur dir, layer='shapefile to import'
   states4 <- readOGR(dsn = ".", layer = "na_states_wgs")  
   states4  # examine; NOTE readOGR automatically assigns projection (coord. ref)
## change import projection (WGS84) to desired projection (AEA)
   states5 <- spTransform(states4, CRS = CRS(prj.aea))
   states5  # examine; NOTE change in projection (ccord.ref)

## import and convert a shapepoly to a raster (grid)
##   assumes a "base" grid from elsewhere for raster conversion; here => ext.rast
   soil.raw <- readOGR(dsn = ".", layer = "soils")  # be patient here ... ~3 min runtime
   soil.raw  # examine; NOTE 
## rasterize the shapepoly to the "base" raster => ext.rast
##   must select attribute to rasterize; use field="attribute name or column No." option
##   be patient here ... ~4-5 min runtimes
   names(soil.raw)  # attribute names to select from
## rasterize 2 selected attributes to a given base raster => ext.rast
   cp.soil.1 <- rasterize(soil.raw, field="phave", ext.rast)
   names(cp.soil.1) <- "phave"
   cp.soil.1  # examine
   cp.soil.2 <- rasterize(soil.raw, field="awc", ext.rast)
   names(cp.soil.2) <- "awc"
   cp.soil.2  # examine

## OR build simple loop to perform all operations

## Create raster layer for each specified field
   soil.var <- c("awc", "phave")  # list of desired variables from shapefile polygon
   soil.list <- list(length(soil.var))  # initialize blank list
## start loop; be patient ... can be time-consuming depending on CPU
##   NOTE ~5 min runtime for this example
for (i in 1:length(soil.var)) {
   ## status breadcrumbs ....
   print("##########");  print("Where the Hell am I in this process????");  print(date())
   print(paste("Step is", i, "of", length(soil.var)));  print(paste("Soil is:", soil.var[i]))
   flush.console()
   ## create stand-alone objects for each soil var; will be in workspace at end of loop
   assign(paste("cp.", soil.var[i], sep = ""), 
          rasterize(soil.raw, ext.rast, field = soil.var[i]))
   ## add each created soil layer to soil list
   soil.list[[i]] <- get(paste("cp.", soil.var[i], sep = ""))
   }
## examine list of output raster & rename
   soil.list  # examine; NOTE is a list of rasters
   names(soil.list) <- soil.var

####
######## END MODULE 2.2 ########

