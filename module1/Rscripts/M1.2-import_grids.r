######## START MODULE 1.2 ########
#### OBJECTIVES:  
####   1:Import different grid formats, projections, resolutions as raster objects
####     Make all same projection (WGS84) and resolution (1km)
####   2:Import a polygon shapefile and create a gridded representation
####
#### This vignette requires data objects from GIS #5 (GIS05.RData)
####
#### tested on R versions 3.1.X, 3.2.X

## available raster builds
##   fxn raster handles filetypes:
##     File type  Long name                extension  Multiband?
##     raster     ’Native’ raster package  .grd       Yes
##     ascii      ESRI Ascii               .asc       No
##     SAGA       SAGA GIS                 .sdat      No
##     IDRISI     IDRISI                   .rst       No
##     CDF        netCDF (requires ncdf)   .nc        Yes
##     GTiff      GeoTiff (requires rgdal) .tif       Yes
##     ENVI       ENVI .hdr Labelled       .envi      Yes
##     EHdr       ESRI .hdr Labelled       .bil       Yes
##     HFA        Erdas Imagine Images     .img       Yes
## for overview of all package raster fxns, see:
##   http://127.0.0.1:13867/library/raster/html/raster-package.html

## some needed libraries
   library(maptools) # fxns: readShapePoly
   library(raster)   # fxns: raster, crop, aggregate, disaggregate, resample
   library(rgdal)    # fxns: readOGR
## some initializations
   path.root <- "~/IALE2015_gisRcourse"
   path.dat <- paste(path.root, "/data", sep = "")
## some projections as in Module 1.1
   prj.wgs84 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"
## some objects from GIS #5
   setwd(path.dat)
   load("outdata/GIS05.RData")  # some shapefiles from Module1.1

## build raster from .img
##   NOTE: format assignment (ie "File type" from above) not always needed, but play it safe
   elev1km.wgs84 <- raster("elev_1k_wgs.img", format = "HFA")  # naive call; imports .img
   elev1km.wgs84  # examine raster attributes
## plot elev raster & CP poly
   plot(elev1km.wgs84)
   plot(cp.poly, add = T)

## build raster & crop to another extent during import to reduce overhead
##   NOTE: input & crop extent must be same projection & resolution
##   Assume a "crop" raster from elsewhere; here "ext.rast" as developed in GIS #5
##   fxn crop => package raster; 1st arg => raster input, 2nd arg => crop extent
   cp.elev1km.wgs84 <- crop(raster("elev_1k_wgs.img", format = "HFA"), ext.rast)
   cp.elev1km.wgs84  # examine
## plot large extent & cropped extent
   par(mfrow = c(1, 2))
   plot(elev1km.wgs84)  # large extent plot
   plot(ext.rast, add = T, col = "red")  # add cp extent
   plot(cp.poly, add = T)  # add cp poly
   plot(cp.elev1km.wgs84)  # small crop extent plot
   plot(cp.poly, add = T)  # add cp poly
   par(mfrow = c(1, 1))

## build raster from ENVI w/.hdr; flat ascii
   ndvi500m.wgs84 <- raster("N200530602133CBR_v1.1.dat", format = "ENVI")
   ndvi500m.wgs84  # examine raster attributes
## plot ENDVI raster & CP poly
   plot(ndvi500m.wgs84)
   plot(cp.poly, add = T)

## build raster from mulit-band landsat file; naive call
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

## up-scale 500m to 1km (ie lower, larger cell) resolution 
##   OR 
## down-scale 500m to 250m (ie higher, smaller cell) resolution
##   fxn aggregate => package raster to up-scale
##     1st object in fxn is raster to resample (ndvi500m.wgs84)
##     2nd object fact= is desired rXc resampling; 2 => 2-500mX2-500m cells => 1-1km cell
##     3rd object method= is resampling method; here bilinear given continuous values
   ndvi1km.wgs84 <- aggregate(ndvi500m.wgs84, fact = 2, method = "bilinear")  # be patient ...
   ndvi500m.wgs84
   ndvi1km.wgs84  # examine resolution change 500m vs. 1km

##   NOT RUN; fxn disaggregate => package raster to down-scale
##     fxn arguments as above for aggregate
   #ndvi250m.wgs84 <- disaggregate(ndvi500m.wgs84, fact = 2, method = "bilinear")  # NOT RUN; be patient if run ...

##   NOT RUN; fxn resample => alternative to aggregate
##     DO NOT USE to create rasters of higher resolution (ie smaller cells)
##     1st object in fxn is raster to up-scale
##     2nd object in fxn is raster with desired resolution
##     3rd object method= is resampling method; here bilinear given continuous values
   #ndvi1km.wgs84 <- resample(ndvi500m, ext.rast, method = "bilinear") # NOT RUN

## build raster from geotif .tif
##   example is "precipitation of driest month" from WORLDCLIM
   precdry1km.wgs84 <- raster("bio14_12.tif", format = "GTiff")
   plot(precdry1km.wgs84)
   plot(cp.poly, add = T)  # examine plots

## build raster from ARC INFO file
   rough1km.wgs84 <- raster("rough_1k")
   plot(rough1km.wgs84)
   plot(cp.poly, add = T)  # examine plots

## input and crop a shapepoly
   soil.rawpoly <- readOGR(dsn = ".", layer = "soil_v13")  # be patient here ...
   #soil.rawpoly <- readShapePoly("soil_v13", proj4string = CRS(prj.wgs84))  # maptools option
   soil.croppoly <- crop(soil.rawpoly, ext.rast)  # ext buf from above
   soil.croppoly  # examine
   names(soil.croppoly)  # NOTE attribute names
## some plots
   plot(ext.rast, col = "grey95")  # background buffer extent
   plot(cp.poly, col = "red", add = T)  # CP poly
   plot(soil.croppoly, add = T)  # add shapefile lines on top of CP $ extent plots

## NOT RUN; output selected rasters
   #save(elev1km.wgs84, cp.elev1km.wgs84, ndvi500m.wgs84, ndvi1km.wgs84, precdry1km.wgs84, 
   #     rough1km.wgs84, soil.croppoly, 
   #     file = "outdata/mod1.2.RData")
######## END MODULE 1.2 ########
 
