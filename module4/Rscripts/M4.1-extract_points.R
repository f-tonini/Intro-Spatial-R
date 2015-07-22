# Module 4.1: Extract raster values from a file of points
# IALE 2015 R GIS Workshop
# July 7, 2015
  
# Goals: 
### Learn how to apply point data to raster- and vector-based data, 
#extract the data associated with each point, and generate a data 
#file for use in other analyses. Learn how to analyze raster- and 
#vector-based data, applying common and customized statistical 
#analyses to single or multiple data layers.
  
#####################################################################
## R Packages Needed	
library(sp)	
library(rgdal)	
library(raster)
	
## Set Your Working Directory	
# Change this to the correct path name on your machine	
setwd("~/Documents/IALE2015_StudentWorkshop/module4")

#####################################################################
# Load shapefile of Juniperus osteosperma point data that you created 
# in module 1
juos <- readOGR(dsn = "data/outdata", layer = "juos_pts_wgs84")  

# Load rasters for elevation, slope and aspect
elev1k.wgs <- raster("data/elev_1k_wgs.img")
slp1k.wgs <- raster("data/slp_1k_wgs.img")
asp1k.wgs <- raster("data/asp_1k_wgs.img")

# Stack rasters into single object. Earlier, you used RasterStacks.
# This time, let's use a RasterBrick. They are very similar, but 
# RasterBricks can be faster for computation. RasterStacks can access
# layers without keeping them all in memory, so that can be an 
# advantage, too. It just depends on your needs.
topo1k.wgs <- brick(elev1k.wgs, slp1k.wgs, asp1k.wgs)

# take a look at the brick.
topo1k.wgs

# let's shorten the names of the layers in the brick.
names(topo1k.wgs) <- c("elev", "slp", "asp")
topo1k.wgs

# Load shapefile for soil
soil <- readOGR(dsn = "data", layer = "soils")

# Take a look at what kinds of data are in this object
summary(soil)

# Load Colorado Plateau polygon. It will be useful for cropping and masking
cp.latlong <- readOGR(dsn = "data", layer = "COP_boundpoly_wgs84")

#####################################################################
## Crop and Mask Data
# Crop elevation raster to a bounding box that fits around the Colorado Plateau
topo.bbox <- crop(topo1k.wgs, cp.latlong)

# Mask elevation raster to include only data within the Colorado Plateau polygon
topo.cp <- mask(topo.bbox, cp.latlong)

## Crop Vector Data
# In the case of vector data, you can still use the crop function.
# However, it does in one function what both crop + mask do for raster data.
soil.cp <- crop(soil, cp.latlong)

## Visualize Rasters and Points
# Take a look at the rasters
plot(topo.cp)

# Plot individual raster with points overlaid
plot(topo.cp$elev)

# Add in add = TRUE or add = T to add points to the same plot
plot(juos, cex = 0.3, pch=19 ,col=c("red","blue"), add=T)
legend("topleft",fill=c("red","blue"), legend = c("0","1"), bty="n")

### Soils
# This will fill all the polygons in the soil object with orange.
plot(soil.cp, col="orange")

# Alternatively, we can fill it with colors corresponding to data from 
# one of the soil variables.
plot(soil.cp, col=soil.cp$taxorder)
plot(juos, cex = 0.3, pch=19 ,col=c("red","blue"), add=T)
legend("topleft",fill=c("red","blue"), legend = c("0","1"), bty="n")

## Extract values
# Extract values from rasters
topo.vals <- extract(topo.cp, juos, method="simple")

# It's always a good idea to check on your data, since you can't see it. 
# This shows us the number of values extracted from rasters. 
# Then we can compare it with the number of points.
dim(topo.vals)
dim(coordinates(juos))

# This shows the number of rows and columns of coordinate data, 
# so we want it to be the same number of rows as the values above, 
# and 2 columns wide, for x and y coordinates.
# Alternatively, you can just test if the number of rows are equal
# with the "==" operator.
nrow(coordinates(juos)) == nrow(topo.vals)

## Extract points from vector data
# Even though crop and extract are from the raster package, 
# they have been made to work on vector data, too.
soil.vals <- extract(soil.cp, juos, method="simple")

# Let's look at the dimensions of the data frame we just created. 
# Because the vector data represent many soil characteristics, 
# it has created a data frame that contains many columns.
dim(soil.vals)

## Combine extracted values into a data frame
extract_juos <- data.frame(juos$coords.x1, 
                      juos$coords.x2, 
                      juos$juos, 
                      topo.vals,
                      soil.vals)

# Now take a look at the top end of our data frame.
head(extract_juos)

# The names of the columns are less than ideal. 
# One way to give them better names is to write them 
# into the data frame in the first place.
extract_juos <- data.frame(X=juos$coords.x1, 
                      Y=juos$coords.x2, 
                      juos=juos$juos, 
                      topo.vals,
                      soil.vals)

# Now export the data as a .csv file for storing and accessing.
write.csv(extract_juos, "data/outdata/extract_juos.csv")

# Take a look at the .csv file in MS Excel or another 
# spreadsheet You'll notice that the first column contains 
# row numbers, which we probably don't really want. 
# So let's find out how to get rid of those. 
# Let's use the quickest way to get help with functions (which I use very often).
?write.csv

# The documentation for write.csv will help you to figure out that 
# row.names=FALSE will allow you to get rid of that first column, so let's do that.
write.csv(extract_juos, "data/outdata/extract_juos.csv", row.names=F)

# Let's also export our other files.
# You can export the rasters into the same file, as long as you use
# a file type that supports multiple bands, like .tif
writeRaster(topo.cp, "data/outdata/topo_cp.grd", format="raster")

# Write soils data
writeOGR(soil.cp, "data/outdata/soil", "soil", "ESRI Shapefile")
