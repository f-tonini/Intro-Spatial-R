#' ## START MODULE 2.4
#' Objective: Edit extent, projection, dimension, resolution of raster layers or shapefiles
#' 
#' tested on R versions 3.1.X, 3.2.X
#' 
#' Load packages and set working directory
#+ load packages
   library(rgdal)     # fxns: readOGR, writeOGR
   library(raster)    # fxns: crop, mask
#  set path
   path.root <- "~/Documents/Intro-Spatial-R/"
   path.mod <- paste(path.root, "module2", sep = "")
   setwd(path.mod)
#'
#' ### Crop a polygon file to another polygon
#' Import shapefile to be altered
#' 
#+ import shapefile 
#  CP study area; the "mask" for cropping
   cp.region <- readOGR(dsn = "data", layer = "COP_boundpoly_aea")
   class(cp.region)  # examine class

#  North American states/provinces to be altered
   states <- readOGR(dsn = "data", layer = "na_states_aea")
   class(states)  # examine class
#'
#' Subset states (UT, AZ, CO, NM) in Colorado Plateau region 
#'  - NOTE: str() to determine shapefile characteristics
#'     here, states$CODE returns all state-based codes
#'  - NOTE: rgdal can be squirrelly, requiring NAs to be excluded, it crashes if NA present
#'
#+ subset states
   head(states@data)  # examine shapepoly data
   states$CODE  # state codes
   cp.states <- states[states$CODE == "UT" | states$CODE == "CO" | 
                             states$CODE == "NM" | states$CODE == "AZ", ]
   
#    cp.states <- states[states$CODE == "UT" & !is.na(states$CODE) | 
#                        states$CODE == "CO" & !is.na(states$CODE) | 
#                        states$CODE == "NM" & !is.na(states$CODE) | 
# 	                   states$CODE == "AZ" & !is.na(states$CODE), ]
   cp.states@data  # examine subsetted states
#'
#+ giggle plots
   plot(states)# all of North America
   plot(cp.states, add = T, col = "blue")# the subsetted states
   plot(cp.region, add = T, col = "red")# the study region, taking long time
#'
#' Crop states to the CP region
#' 
#+ crop states  
   cp.statesCROP <- crop(cp.states,cp.region)
   plot(cp.states)  # giggle plot
## output shapefile if desired; examine in ArcGIS if desired
   # writeOGR(cp.statesCROP, dsn = "./outdata", layer = "cp.statesCROP", 
   # morphToESRI = T, driver = "ESRI Shapefile")
#'
#' ### Polygon crop of raster
#' This is a 2-step process that is easy to construct as function if desired.
#' 
#+ import raster
   tave <- raster("data/tave_yr_av.img")
   tave  # examine raster
   summary(cp.region)  # examine crop polygon (from above)
#'   
#' Note the different projections; must convert 1 to match other (see Module 2.2)
#' 
#+ transform to match projections
   cp.regionWGS <- spTransform(cp.region, CRS = CRS(projection(tave)))
   cp.regionWGS  # now same projection as tave
   
## giggle plots; goal is crop of tave to match red in plot
   plot(tave)
   plot(cp.regionWGS, add = T, col = "red")
#'   
#' Step #1; `mask()` function w/CP polygon as the mask applied to tave
#' 
#+ mask tave
   taveCROP.1 <- mask(tave, cp.regionWGS)
   
## giggle plots; LOL here .....
   plot(taveCROP.1)# NOTE extent is extent of tave
   plot(extent(taveCROP.1), add = T)
#'   
#' Step #2; `crop()` function to subset the masked tave to the extent of the CP region
#' 
#+ crop tave to CP region
   taveCROP.2 <- crop(taveCROP.1, cp.regionWGS)
   
## giggle plots ...
   plot(taveCROP.2)
   plot(cp.regionWGS, add = T)
   
## outfile cropped raster if desired
   #writeRaster(taveCROP.2, filename = "outdata/cp.taveCROP2.img", format = "HFA")
#'
#' ### Crop raster using another raster
#' Assume raster of region to serve as crop; here cp.rast (see Module 2.2)
#'
#+ crop raster by raster 
   ext.rast <- raster(resolution = 0.008333333, extent(cp.regionWGS))
   cp.rast <- rasterize(cp.regionWGS, field = "Id", ext.rast)
   cp.rast  # examine
   
## raster to be cropped
## same projection/resolution as cp.rast?  if not see Module 2.3
   tave  # examine
   
## some giggle plots; crop goal is red
   plot(tave)
   plot(cp.rast, add = T, col = "red")
   
## crop tave raster w/cp.rast raster
   taveCROP.3 <- crop(tave, cp.rast)
   
## write out file of cropped raster if desired
   #writeRaster(taveCROP.3, filename = "outdata/cp.taveCROP3.img", format = "HFA")
   
## giggle plots; NOTE that crop is the cp.rast extent, not just CP region
   plot(taveCROP.3)
   plot(cp.rast, add = T, col = "red")
   
## giggle plots
   par(mfrow = c(1, 2))
   plot(taveCROP.3)
   plot(cp.regionWGS, add = T, border = "black")

## outfile cropped raster if desired
   #writeRaster(taveCROP.3, filename = "outdata/cp.taveCROP3.img", format = "HFA")
#'
#' Crop a polygon to a raster
#'
#+ load shapefile 
   soil <- readOGR(dsn = "data", layer = "soils")  # be patient here ... ~3 min runtime
   soil # examine polygon
   cp.rast # examine raster; both have same projection?  if not see Module 2.2/2.3
   
## crop polygon w/extent of raster
   soilCROP.1 <- crop(soil,extent(cp.rast))
## giggle plots
   par(mfrow = c(1, 2))
   plot(soil)
   plot(cp.regionWGS, add = T, col = "red")
   plot(soilCROP.1)
   plot(cp.rast, add = T, col = "red")
#'
#' ## END MODULE 2.4
#' 
#' Create R markdown file from R script   
#+
   knitr::spin("Rscripts/M2.4-alterextent_shapefileraster.r", knit = F, format = "Rmd")
