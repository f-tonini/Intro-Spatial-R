#' ---	
#' title: 'Module 3: Modifying GIS Data in R'	
#' author: "IALE 2015 R GIS Workshop"	
#' date: "June 8, 2015"	
#' output:	
#'   html_document:	
#'     keep_md: yes	
#'     toc: yes	
#'   pdf_document:	
#'     toc: yes	
#' ---	
#' 	
#' # Goal: Learn how to access and modify raster and vector data	
#' 	
#' ## R Packages Needed	
#' 	
#' 	
library(sp)	
library(rgdal)	
library(raster)	
library(latticeExtra)	
#' 	
#' 	
#' ## Set Your Working Directory	
#' 	
#' Change this to the correct path name on your machine	
#' 	
#' 	
setwd("~/Documents/IALE2015_StudentWorkshop/IALE2015_gisRcourse")	
#' 	
#' 	
#' This is the syntax for the path on an Apple/Mac for a subfolder in the `Documents` directory.	
#' 	
#' ## Read in Shapefiles	
#' 	
#' Here we import a polygon boundary of the state of Utah and a set of polygons representing game management units within the state.	
#' 	
#' 	
utah.wgs84 <- readOGR(dsn = "data", layer = "utah_wgs84") # Utah border, for "pretty" plotting	
deer_unit <- readOGR(dsn = "data", layer = "deerrange_UT") # Game management units	
#' 	
#' 	
#' Take a look at the game management data we loaded	
#' 	
#' 	
summary(deer_unit)	
#' 	
#' 	
#' This tells us the characteristics of the object, as well as giving a summary of the attribute data stored in the data table. The attribute data is stored in a slot called `@data` so if we just want to look at the data stored in the object:	
#' 	
#' 	
summary(deer_unit@data)	
names(deer_unit) # The attribute data names	
#' 	
#' 	
#' The `@data` slot is in fact a class `data.frame` like would be most other tables loaded into `R`, while the entire object is a Spatial Polygons Data Frame.	
#' 	
#' 	
class(deer_unit)	
class(deer_unit@data)	
#' 	
#' 	
#' Make a basic plot with coloring based on `UName`	
#' 	
#' 	
plot(deer_unit, 	
     axes = TRUE, # adds the coordinate ranges to the axes	
     col = deer_unit$UName, # colors the polygons based on UName	
     main = "Utah Game Management Units" # adds main title to plot	
     )	
plot(utah.wgs84, add = TRUE) # Add the Utah border for reference	
#' 	
#' 	
#' Use the `spplot` function from `sp` package to provide coloring and a legend based on the `UName` (unit name) attribute of the management units.	
#' 	
#' 	
spplot(deer_unit, c("UName"), 	
       scales = list(draw = TRUE), # this adds the coordinate values to the plot	
       main = "Utah Game Management Units" # adds title to map	
       # ,sp.layout = list("sp.polygons", utah.wgs84) # adds Utah border to map within call to `spplot` function	
       ) +	
      layer(sp.polygons(utah.wgs84)) # alternative way to add layers to map; requires `latticeExtra` package	
#' 	
#' 	
#' ## Querying data of a vector (shapefile)	
#' 	
#' Querying the data in a shapefile is much the same as querying any other data frame in `R`. For example, if you want to look at the data only for the West Desert unit:	
#' 	
#' 	
wd <- deer_unit[deer_unit$UName == "West Desert",]	
summary(wd)	
plot(wd)	
plot(deer_unit, main = "West Desert Game Management Unit")	
plot(utah.wgs84, add = TRUE)	
plot(wd, add = TRUE, col = "red")	
#' 	
#' 	
#' Or perhaps you just want to have a quick look at how many deer are in the Box Elder unit:	
#' 	
#' 	
deer_unit@data$DEER[deer_unit@data$UName == "Box Elder"]	
#' 	
#' 	
#' Note that these are base `R` methods for indexing. There are also several frequently used packages that have been built to help with manipulation of data as needs become more complex, e.g. `plyr`, `dplyr`, `data.table` as three well known packages.	
#' 	
#' ## Calculate a new field for vector data	
#' 	
#' Calculating a new field is as easy as adding a new column to any other data frame in `R`. Say we want to calcualte a new field from the existing data, such as the total number of adult deer and elk in each management unit:	
#' 	
#' 	
deer_unit$tot_deer_elk <- rowSums(cbind(deer_unit$DEER, deer_unit$ELK))	
summary(deer_unit@data)	
#' 	
#' 	
#' Plot the management units with color based on this new field:	
#' 	
#' 	
spplot(deer_unit, c("tot_deer_elk"), scales = list(draw = TRUE), main = "Deer + Elk Totals - Utah Game Management Units") +	
      layer(sp.polygons(utah.wgs84))	
#' 	
#' 	
#' ## Convert raster to vector and vector to raster	
#' 	
#' In another scenario, perhaps we want to add some data from a raster, such as a gridded surface of NDVI. 	
#' 	
#' First, let's read in the NDVI raster surface	
#' 	
#' 	
ndvi500m.wgs84 <- raster("data/N200530602133CBR_v1.1.dat", format = "ENVI")	
ndvi500m.wgs84	
names(ndvi500m.wgs84) <- "ndvi" # Change raster attribute name	
#' 	
#' 	
#' Note that the projection is in decimal degrees and thus the grain and extent are also given in decimal degrees. Next, check that the projections are all the same:	
#' 	
#' 	
all.equal(proj4string(deer_unit), proj4string(utah.wgs84), proj4string(ndvi500m.wgs84))	
#' 	
#' 	
#' The `all.equal` function returns `TRUE` if the objects are all the same, and `FALSE` otherwise. So, all of these layers have exactly the same `proj4` string. 	
#' 	
#' 	
#' Plotting the layers we see that the NDVI surface is much larger than our area of interest, in fact covering much of the southwestern United States.	
#' 	
#' 	
plot(ndvi500m.wgs84)	
plot(utah.wgs84, add = TRUE)	
plot(deer_unit, add = TRUE)	
#' 	
#' 	
#' So, we can crop the raster to an area that's a little smaller:	
#' 	
#' 	
ndvi_utah <- crop(ndvi500m.wgs84, extent(utah.wgs84))	
plot(ndvi_utah)	
plot(utah.wgs84, add = TRUE)	
plot(deer_unit, add = TRUE)	
#' 	
#' 	
#' Now we can create a new raster of the management units based on the NDVI raster's grain and extent. This is necessary for "masking" the data from a raster with a larger extent.	
#' 	
#' 	
system.time(deer_unit.rast <- rasterize(deer_unit, ndvi_utah, deer_unit$UNum)) # note this took about 5 seconds on my 16 GB RAM laptop	
deer_unit.rast	
names(deer_unit.rast) <- "UNum"	
	
## Examine plots; colors correspond to the value of UNum	
plot(deer_unit.rast) # note that this retains the extent of the input raster	
plot(deer_unit, add = TRUE)	
plot(utah.wgs84 , add = TRUE)	
#' 	
#' 	
#' 	
#' The raster surface can be converted to a polygon, but now will only have the single attribute assigned to the layer when it was rasterized.	
#' 	
#' 	
system.time(deer_unit2 <- rasterToPolygons(deer_unit.rast))	
# This took about 17 seconds	
summary(deer_unit2)	
names(deer_unit2)	
#' 	
#' 	
#' ## Subsetting/masking data for analysis	
#' 	
#' We can use the deer unit raster, which matches the extent, grain, and projection of the NDVI data, to summarize some of the NDVI raster based on the management units. This way we will be able to add these data back to the `deer_unit` Spatial Polygons Data Frame. Here we are going to calculate the mean NDVI for each management unit.	
#' 	
#' 	
# Calculate the mean	
x.deer_unit <- as.data.frame(zonal(ndvi_utah, deer_unit.rast, mean, na.rm = TRUE))	
names(x.deer_unit) <- c("UNum","avg.ndvi")	
# summary(x.deer_unit)	
#' 	
#' 	
#' Now merge this data frame back to the `deer_unit` object:	
#' 	
#' 	
deer_unit@data <- merge(deer_unit@data, x.deer_unit, 	
                        by = "UNum", # column name to merge on	
                        all.x = TRUE # adds extra rows with NAs when no matches in second object; in other words, retains all of deer_unit data	
                        )	
	
# The avg.ndvi column and values have been added to @data in deer_unit	
names(deer_unit)	
summary(deer_unit@data)	
#' 	
#' 	
#' ## Subset for a single polygon	
#' 	
#' The same process can be done for a single polygon. Recall that we subset the Western Desert management unit, now the `wd` object in our workspace.	
#' 	
#' 	
summary(wd)	
	
# Create raster of wd polygon	
wd.rast <- rasterize(wd, ndvi_utah, wd$UNum)	
plot(deer_unit, axes = TRUE)	
plot(wd.rast, add = TRUE)	
plot(utah.wgs84, add = TRUE)	
	
# Calculate mean NDVI for this polygon	
x.deer_unit <- as.data.frame(zonal(ndvi_utah, wd.rast, mean, na.rm = TRUE))	
names(x.deer_unit) <- c("UNum","avg.ndvi")	
	
# Merge NDVI data back to wd 	
wd@data <- merge(wd@data, x.deer_unit, by = "UNum", all.x = TRUE)	
	
# Note that the values for avg.ndvi are the same for the single polygon and for the same unit number in the larger data set	
summary(wd@data) 	
summary(deer_unit[deer_unit$UNum == 19,])	
#' 	
#' 	
#' ## Plot management units with average NDVI	
#' 	
#' 	
spplot(deer_unit, c("avg.ndvi"), scales = list(draw = TRUE), main = "Average NDVI in Utah Game Management Units") +	
      layer(sp.polygons(utah.wgs84))	
#' 	
#' 	
#' ## Write out spatial polygons shapefile	
#' 	
#' We will export the `deer_unit` object to a new shapefile in the `outdata` subfolder with the name `deer_rangeUT_2`.	
#' 	
#' 	
writeOGR(deer_unit, dsn = "data/outdata", layer = "deer_rangeUT_2", driver = "ESRI Shapefile", overwrite_layer = TRUE)	
#' 	
