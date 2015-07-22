######## START MODULE 2.4 ########
#### OBJECTIVE:  
####   Ensures all raster layers are of same extent, projection, dimension, resolution
####
#### Requires data objects from module #1 (module1.RData) & module #2.1 (module2.1.RData)
####
#### tested on R versions 3.1.X, 3.2.X

## some libraries ...
   library(rgdal)     # fxns: readOGR, writeOGR
   library(raster)    # fxns: crop, mask
## some initializations ...
   #path.root <- "~/IALE2015_gisRcourse"
   #path.dat="E:/IALE2015_gisRcourse/data"
   path.root <- "~/words/classes/IALE2015_gisRcourse"
   path.dat <- paste(path.root, "/data", sep = "")
   setwd(path.dat)

   
####
## polygon crop of polygon
##   import shapefile to be altered 
##   CP study area; the "mask" for cropping
   cp.region <- readOGR(dsn = ".", layer = "COP_boundpoly_aea")
   class(cp.region)  # examine class
##   north American states/provinces to be altered
   states <- readOGR(dsn = ".", layer = "na_states_aea")
   class(states)  # examine class

## subset states (UT, AZ, CO, NM) in Colorado Plateau region 
##   NOTE: str() to determine shapefile characteristics
##     here, states$CODE returns all state-based codes
##   NOTE: rgdal squirrelly; must exclude NA or crashes if NA present
   head(states@data)  # examine shapepoly data
   states$CODE  # state codes
   cp.states <- states[states$CODE == "UT" & !is.na(states$CODE) | 
                       states$CODE == "CO" & !is.na(states$CODE) | 
                       states$CODE == "NM" & !is.na(states$CODE) | 
	                   states$CODE == "AZ" & !is.na(states$CODE), ]
   cp.states@data  # examine subsetted states
## giggle plots
   plot(states)  # all states
   plot(cp.states, add = T, col = "blue")  # the subsetted states
   plot(cp.region, add = T, col = "red")  # the study region
## crop states to the CP region   
   cp.statesCROP=crop(cp.states,cp.region)
   plot(cp.states)  # giggle plot
## output shapefile if desired; examine in ArcGIS if desired
   #writeOGR(cp.statesCROP, dsn = "./outdata", layer = "cp.statesCROP", 
   #  morphToESRI = T, driver = "ESRI Shapefile")
####

####
## polygon crop of raster
## a 2-step process; easy to construct as fxn if desired
##   import a raster to crop
   tave <- raster("tave_yr_av.img")
   tave  # examine raster
   cp.region  # examine crop polygon (from above)
## NOTE diff projections; must convert 1 to match other (see Module 2.2)
   cp.regionWGS <- spTransform(cp.region, CRS = CRS(projection(tave)))
   cp.regionWGS  # now same projection as tave
## giggle plots; goal is crop of tave to match red in plot
   plot(tave)
   plot(cp.regionWGS, add = T, col = "red")
## step #1;  fxn mask() w/CP polygon as mask applied to tave
   taveCROP.1 <- mask(tave, cp.regionWGS)
## giggle plots; LOL here .....
   plot(taveCROP.1)  # NOTE extent is extent of tave
   plot(extent(taveCROP.1), add = T)
## step #2; fxn crop() to subset masked tave to extent of CP region
   taveCROP.2 <- crop(taveCROP.1, cp.regionWGS)
## giggle plots ...
   plot(taveCROP.2)
   plot(cp.regionWGS, add = T)
## outfile cropped raster if desired
   #writeRaster(taveCROP.2, filename = "outdata/cp.taveCROP2.img", format = "HFA")
####

####
## raster crop of raster
## assume raster of region to serve as crop; here cp.rast (see Module 2.2)
   load("outdata/cp.rast.RData")  # raster of CP region
   cp.rast  # examine
## raster to be cropped; same projection /resolution as cp.rast?  if not see Module 2.3
   tave  # examine
## some giggle plots; crop goal is red
   plot(tave)
   plot(cp.rast, add = T, col = "red")
## crop tave raster w/cp.rast raster
   taveCROP.3 <- crop(tave, cp.rast)
## outfile cropped raster if desired
   #writeRaster(taveCROP.3, filename = "outdata/cp.taveCROP3.img", format = "HFA")
## giggle plots; NOTE that crop is cp.rast extent, not just CP region
   plot(taveCROP.3)
   plot(cp.rast, add = T, col = "red")
## mulitply rasters if desire cp.rast only; otherwise default is rectangle of extent
   taveCROP.4 <- cp.rast * taveCROP.3  # NOTE; cp.rast has value => NA outside of CP per se
## giggle plots
   par(mfrow = c(1, 2))
   plot(taveCROP.3)
   plot(cp.regionWGS, add = T, border = "black")
   plot(taveCROP.4)
   plot(cp.regionWGS, add = T, border = "black")
## outfile cropped raster if desired
   #writeRaster(taveCROP.4, filename = "outdata/cp.taveCROP4.img", format = "HFA")
####
   
####
## raster crop of polygon
   soil <- readOGR(dsn = ".", layer = "soils")  # be patient here ... ~3 min runtime
   soil  # examine polygon
   cp.regionWGS  # examine raster; both have same projection?  if not see Module 2.2/2.3
## crop polygon w/extent of raster
   soilCROP.1=crop(soil,extent(cp.regionWGS))
## giggle plots
   par(mfrow = c(1, 2))
   plot(soil)
   plot(cp.regionWGS, add = T, col = "red")
   plot(soilCROP.1)
   plot(cp.regionWGS, add = T, col = "red")
####
######## END MODULE 2.4 ########

