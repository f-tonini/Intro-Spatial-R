#' ## START MODULE 2.3
#' 
#' Objective: Ensure all raster layers are of same extent, projection, dimension, resolution
#' 
#' tested on R versions 3.1.X, 3.2.X
#' 
#' #### Load packages
#' 
#+ load packages
   library(raster)    # fxns: raster, projectRaster, stack
   library(rgdal)
#'
#' Some initializations: set working directory/path to data
#' Refer to Module 1.1 for help on setting your path and working directory
#' 
#+ set working directory
   #path.root <- "~/IALE2015_gisRcourse"
   path.root <- "~/Documents/Intro-Spatial-R/"
   path.mod <- paste(path.root, "module2", sep = "")
   setwd(path.mod)
#'
#' #### Load some GIS data layers
#'
#+ create base raster
   cp.wgs <- readOGR(dsn = "data", layer = "COP_boundpoly_wgs84")
   ext.rast <- raster(resolution = 0.008333333, extent(cp.wgs), crs = proj4string(cp.wgs))
#'   
#+ load rasters 
   # in WGS84 projection: 
   elev1km.wgs84 <- raster("data/elev_1k_wgs.img") 
   ndvi500m.wgs84 <- raster("data/N200530602133CBR_v1.1.dat")
   precdry1km.wgs84 <- raster("data/bio14_12.tif")
   rough1km.wgs84 <- raster("data/rough_1k")

   # in Albers Equal Area projection
   cp.nlcd30m.aea <- raster("data/cpBOX.img")
   
   # add a new raster for this module ...
   taveYrAvg1km.wgs84 <- raster("data/tave_yr_av.img")
#'
#+ load soil shapefile. 
   # This may take a little time
   soil.rawpoly <- readOGR(dsn = "data", layer = "soils")
#'
#' #### Examine existing rasters
#' 
#' Note which are different class, resolution, extent, etc. ALL need to match ext.rast (i.e. be identical in projection, extent, resolution), otherwise you won't have accurate calculations and R won't like you ...
#' 
#'  - `ext.rast`, the base raster to which ALL must match
#'  - `elev1km.wgs84`, elev 1km raster
#'  - `ndvi1km.wgs84`, NDVI raster at 1km resolution
#'  - `precdry1km.wgs84`, precip at 1km raster
#'  - `rough1km.wgs84`, terrain roughness 1km raster
#'  - `cp.nlcd30m.aea`, NLCD at 30m resolution, AEA projection
#'  - `taveYrAvg1km.wgs84`, mean annual temperature raster, 1km resolution
#'
#' Compare each raster to the base raster, i.e. `ext.rast` and adjust to common projection, resolution, and extent as needed.
#' 
#' The function `projectRaster` from the `raster` package is the easiest, repeatable method to ensure equal rasters. It makes all projections, resolutions, and extents equal to a base raster, applying a bilinear interpolation by default. Choose another method using `method = "method"` in the function call, e.g. `method = "ngb"` for nearest neighbor.
#'
#+ check rasters 
   # examine elev1km.wgs84 vs. ext.rast; NOTE <1 min runtime
   ext.rast;  elev1km.wgs84# NOTE different extent, dimensions
   cp.elev <- projectRaster(elev1km.wgs84, ext.rast)
   ext.rast;  cp.elev  # examine; now identical ??
   names(cp.elev) <- "elev";  cp.elev  # apply rename option

   # examine ndvi1km.wgs84 vs. ext.rast; NOTE <1 min runtime
   ext.rast;  ndvi500m.wgs84# NOTE wrong extent, dimensions, resolution
   cp.ndvi <- projectRaster(ndvi500m.wgs84, ext.rast)
   ext.rast;  cp.ndvi  # examine; now identical ??
   names(cp.ndvi) <- "ndvi";  cp.ndvi  # apply rename option

   # examine precdry1km.wgs84 vs. ext.rast; NOTE <1 min runtime
   ext.rast;  precdry1km.wgs84# NOTE wrong extent, dimensions
   cp.precip <- projectRaster(precdry1km.wgs84, ext.rast)
   ext.rast;  cp.precip  # examine; now identical ??
   names(cp.precip) <- "precip";  cp.precip  # apply rename option

   # examine rough1km.wgs84 vs. ext.rast; NOTE <1 min runtime
   ext.rast;  rough1km.wgs84# NOTE wrong extent, dimensions, projection
   cp.rough <- projectRaster(rough1km.wgs84, ext.rast)
   ext.rast;  cp.rough  # examine; now identical ??
   names(cp.rough) <- "rough";  cp.rough  # apply rename option 

   # examine cp.nlcd30m.aea vs. ext.rast; NOTE ~9 min runtime
   ext.rast;  cp.nlcd30m.aea# NOTE wrong extent, dimensions, projection, resolution
   system.time(cp.nlcd <- projectRaster(cp.nlcd30m.aea, ext.rast, method = "ngb"))
   ext.rast; cp.nlcd# examine; now identical ??
   names(cp.nlcd) <- "nlcd"; cp.nlcd# apply rename option

   # taveYrAvg1kmwgs84 vs. ext.rast as base raster; NOTE <1 min runtime
   ext.rast;  taveYrAvg1km.wgs84# NOTE wrong extent, dimension
   cp.taveYrAvg <- projectRaster(taveYrAvg1km.wgs84, ext.rast)
   ext.rast;  cp.taveYrAvg# examine; now identical ??
#'
#' #### Create raster stack
#' A raster stack is a set of rasters with the same projection, extent, resolution, and dimension. You can then perform operations on this single object instead of needing to operate on individual rasters.
#+ stack rasters 
   cp.allvars <- stack(cp.elev, cp.ndvi, cp.precip, cp.rough, cp.taveYrAvg)
   cp.allvars# examine
#'   
#' #### Convert a raster to a polygon 
#' Example: cp.soil.1 => phave from Module 2.2
#' Be patient, this will take some time
#' 
#+ convert raster to polygon
   cp.soil.1 <- rasterize(soil.raw, field="phave", ext.rast)
   cp.soil.1P <- rasterToPolygons(cp.soil.1)
   cp.soil.1  # examine raster of soil => phave
   cp.soil.1P  # examine raster2polygon of soil => phave

#' ## END MODULE 2.3
#' 
#' Create R markdown file from R script 
#+
   knitr::spin("Rscripts/M2.3-modify_raster.r", knit = F, format = "Rmd")
