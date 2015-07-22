# Module 4.2: Analyzing GIS Data in R
# IALE 2015 R GIS Workshop
# July 7, 2015
  
# Goals: 
# Learn how to analyze raster- and vector-based data, applying common 
# and customized statistical analyses to single or multiple data layers.
  
#####################################################################
# Module 4.2: Perform statistics on extracted point data
## R Packages Needed	
library(sp)	
library(rgdal)	
library(raster)
library(fields)
	
## Set Your Working Directory	
# Change this to the correct path name on your machine	
setwd("~/Documents/IALE2015_StudentWorkshop/module4")

#####################################################################
# Reload the data
extract_juos <- read.csv("data/outdata/extract_juos.csv")
topo.cp <- brick("data/outdata/topo_cp.grd")
soil.cp <- readOGR("data/outdata/soil", "soil") 

# Let's make sure it's a data frame type of object, and not something else. 
class(extract_juos)

# Take a look at first and last few lines of the data frame.
head(extract_juos)
tail(extract_juos)

## Raster Statistics
# Let's confirm that our RasterBrick has 3 layers and that everything looks right.
topo.cp

# Let's also note that you can access rasters in the brick using the $ symbol, like
# for columns in data frames and items in lists.
topo.cp$elev

# Compare and analyze rasters. 
pairs(topo.cp)

# pairs is a function that is in the raster package, but it is also serves 
# another purpose in base R.
?pairs

# So how does R know which pairs function to use? It all depends on which 
# class the object is. The raster version of it will only be applied if it's a Raster* object.
class(topo.cp)

# Calculate statistics on rasters
cellStats(topo.cp, stat="mean")
cellStats(topo.cp, stat="sd")

# Simply adding [] at the end of a Raster object gives you the values in the raster. 
# You can apply any of a wide array of R functions to those, instead of just the built-in 
# functions included in cellStats. 
topo.cp[]
topo.cp$elev[]

# Then you can do what you want with the values. Many of these functions require
# you to use the na.rm = TRUE argument so that NAs aren't included in the calculation.
# Here is the mean of elevation.
mean(topo.cp$elev[], na.rm=T)

# Here's how you'd get the mean of all three layers.
colMeans(topo.cp[], na.rm=T)

## Transformations
# You can transform the raster values. For example, take the log of the elevation values.
log(topo.cp$elev[])

# raster package will even know what to do if you apply operations to the raster object. 
# let you do this to the raster object itself. Let's make a new object to hold our log 
# transformed elevation data.
elev.log <- log(topo.cp$elev)

# You could also scale the values from 0 to 1. We'll do that with slope.
slp.scale <- topo.cp$slp/max(topo.cp$slp[], na.rm=T)

# You can analyze the transformed data as you like.
hist(log(topo.cp$elev[]))

# You might want to add a transformed raster into your RasterBrick as an extra layer.
topo.cp$elev.log <- elev.log

# Alternatively, you might want to substitute one of your RasterBrick
# layers with transformed values.
topo.cp$slp[] <- slp.scale[]

## Model Selection
# Let's look at one way to analyze the point data we extracted from the rasters 
# and vectors. First run models on the combinations of covariates of interest. These are 
# run specifically on our extract_juos object with raster and vector data extracted 
# into it. The models we're using here are simple linear models, but there any 
# number of other models to use.
elev.lm = lm(elev ~ juos, data=extract_juos)
asp.lm = lm(asp ~ juos, data=extract_juos)
elev.slp.asp.lm = lm(elev + slp + asp ~ juos, data=extract_juos)
elev.clay.lm = lm(elev + clay ~ juos, data=extract_juos)

# By running AIC on these models, we can compare support in the data for each one. 
#The one with the **lowest** score is the best of the set that you tested.
AIC(elev.lm)
AIC(asp.lm)
AIC(elev.slp.asp.lm)
AIC(elev.clay.lm)

# Aspect appears to be the best fit of these 4 options.

## Interpolate Values Between Points
# Thin plate spline regression 
juos.tps <- Tps(coordinates(juos), juos$juos)

# Create a new raster object that will hold the interpolated data.
juos.int <- elev.cp

# Create an interpolated raster. 
juos.int <- interpolate(juos.int, juos.tps)

# This raster fills the bounding box.
plot(juos.int)

# So let's mask that to the Colorado Plateau perimeter.
juos.int <- mask(juos.int, elev.cp)

# Plot the masked result
plot(juos.int)

# Write the result to file
writeRaster(juos.int, "data/outdata/juos_interpolation.tif")

# You can also save it as a .pdf, .png, or other graphics file type. 
# The first call opens up a new file with the desired name.
pdf("data/outdata/juos_interpolation.pdf")

# The next call fills that file with the data it needs.
plot(juos.int)

# This call closes up the file so it won't get added to if you plot anything else.
dev.off()
