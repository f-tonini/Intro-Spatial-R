######## START MODULE 2.3 ########
#### OBJECTIVE:  
####   Ensures all raster layers are of same extent, projection, dimension, resolution
####
#### Requires data objects from module #1 (module1.RData) & module #2.1 (module2.1.RData)
####
#### tested on R versions 3.1.X, 3.2.X

## some libraries ...
   library(raster)    # fxns: raster, projectRaster, stack
## some initializations ...
   #path.root <- "~/IALE2015_gisRcourse"
   path.root <- "~/words/classes/IALE2015_gisRcourse"
   path.dat <- paste(path.root, "/data", sep = "")
   setwd(path.dat)
## some input GIS layers & characteristics from previous modules ...
##   rasters WGS84: elev1km.wgs84, ndvi1km.wgs84, precdry1km.wgs84, rough1km.wgs84
##   rasters AEA:   cp.nlcd30m.aea
##   shapefiles:    soil.rawpoly
   load("outdata/module1.RData")  # some shapefiles & rasters from module #2.1
   ls()  # examine
   load("outdata/module2.1.RData")  # some rasters from module #1
   ls()  # examine
## add a new raster for this module ...
   taveYrAvg1km.wgs84 <- raster("tave_yr_av.img")  # add another .img ... 


## examine existing rasters; NOTE which are different class, resolution, extent, etc
##   ALL need to match ext.rast (ie. be identical in projection, extent, resolution)
##   OTHERWISE R won't like you ...
##     ext.rast            # the base raster to which ALL must match
##     elev1km.wgs84       # elev 1km raster
##     ndvi1km.wgs84       # NDVI raster at 1km resolution
##     precdry1km.wgs84    # precip at 1km raster
##     rough1km.wgs84      # terrain roughness 1km raster
##     cp.nlcd30m.aea      # NLCD at 30m raster, AEA
##     taveYrAvg1km.wgs84  # avg annual temp 1km raster

## compare each raster to base raster => ext.rast; adjust to common projection, resolution, extent
##   fxn projectRaster => package raster easiest, repeatable method to ensure equal rasters
##     fxn make all projections, resolutions & extents equal to base raster
##     applies a bilinear by default; method="ngb" for nearest neighbor
##
##   elev1km.wgs84 vs. ext.rast as base raster; NOTE <1 min runtime
   ext.rast;  elev1km.wgs84   # examine; NOTE wrong extent, dimensions
   cp.elev <- projectRaster(elev1km.wgs84, ext.rast)
   ext.rast;  cp.elev  # examine; now identical ??
   names(cp.elev) <- "elev";  cp.elev  # apply rename option

##   ndvi1km.wgs84 vs. ext.rast as base raster; NOTE <1 min runtime
   ext.rast;  ndvi1km.wgs84  # examine; NOTE wrong extent, dimensions, resolution
   cp.ndvi <- projectRaster(ndvi1km.wgs84, ext.rast)
   ext.rast;  cp.ndvi  # examine; now identical ??
   names(cp.ndvi) <- "ndvi";  cp.ndvi  # apply rename option

##   precdry1km.wgs84 vs. ext.rast as base raster; NOTE <1 min runtime
   ext.rast;  precdry1km.wgs84  # examine; NOTE wrong extent, dimensions
   cp.precip <- projectRaster(precdry1km.wgs84, ext.rast)
   ext.rast;  cp.precip  # examine; now identical ??
   names(cp.precip) <- "precip";  cp.precip  # apply rename option

##   rough1km.wgs84 vs. ext.rast as base raster; NOTE <1 min runtime
   ext.rast;  rough1km.wgs84  # examine; NOTE wrong extent, dimensions, projection
   cp.rough <- projectRaster(rough1km.wgs84, ext.rast)
   ext.rast;  cp.rough  # examine; now identical ??
   names(cp.rough) <- "rough";  cp.rough  # apply rename option 

##   cp.nlcd30m.aea vs. ext.rast as base raster; NOTE ~9 min runtime
   ext.rast;  cp.nlcd30m.aea  # examine; NOTE wrong extent, dimensions, projection, resolution
      xx=raster("nlcd1.img")
      date(); cp.nlcd <- projectRaster(xx, ext.rast, method = "ngb"); date()
   #cp.nlcd <- projectRaster(cp.nlcd30m.aea, ext.rast, method = "ngb")
   ext.rast; cp.nlcd         # examine; now identical ??
   names(cp.nlcd) <- "nlcd"; cp.nlcd  # apply rename option

##   taveYrAvg1kmwgs84 vs. ext.rast as base raster; NOTE <1 min runtime
   ext.rast;  taveYrAvg1km.wgs84  # examine; NOTE wrong extent, dimension
   date(); cp.taveYrAvg <- projectRaster(taveYrAvg1km.wgs84, ext.rast); date()
   ext.rast;  cp.taveYrAvg        # examine; now identical ??

## create a stack of rasters of same projection, extent, resolution, dimension
   cp.allvars <- stack(cp.elev, cp.ndvi, cp.precip, cp.rough, cp.taveYrAvg)
   cp.allvars  # examine
   
## convert a raster to a polygon; EXAMPLE cp.soil.1 => phave from Module 2.2
##   be patient ... ~3 min runtime
   cp.soil.1P <- rasterToPolygons(cp.soil.1)
   cp.soil.1  # examine raster of soil => phave
   cp.soil.1P  # examine raster2polygon of soil => phave
####
######## END MODULE 2.3 ########

