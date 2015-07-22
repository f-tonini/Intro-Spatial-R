######## START MODULE 2.6 ########
#### OBJECTIVE:  
####   Build a study area map with polygons, lines, & point shapefile input
####   Add a inset of the study region in relation to a larger extent
####
#### No data objects are required for this module
####
#### Tested on R versions 3.1.X, 3.2.X


## some needed libraries
   library(rgdal)     # fxns: readOGR, writeOGR
   library(raster)    # fxns: crop
   library(GISTools)  # fxns: map.scale, north.arrow
## some initializations
   #path.root <- "~/IALE2015_gisRcourse"
   path.root <- "~/words/classes/IALE2015_gisRcourse"
   path.dat <- paste(path.root, "/data", sep = "")
   setwd(path.dat)

## import shapefiles to be used in study area graph 
##   CP study area
   cp.region <- readOGR(dsn = ".", layer = "COP_boundpoly_aea")
##   north american states/provinces for USA, Canada, Mexico
   states <- readOGR(dsn = ".", layer = "na_states_aea")
##   subset states UT, AZ, CO, NM
##     NOTE: str() to determine shapefile attributes; str@data is attributes
##       here, states$CODE returns all state-based codes
##     NOTE: rgdal squirrelly; must exclude NA or crashes if NA present
   states$CODE  # state codes
   cp.states <- states[states$CODE == "UT" & !is.na(states$CODE) | 
                       states$CODE == "CO" & !is.na(states$CODE) | 
                       states$CODE == "NM" & !is.na(states$CODE) | 
	                   states$CODE == "AZ" & !is.na(states$CODE), ]
## NOT RUN; write out subset polygon into ESRI format if desired
   #writeOGR(cp.states, dsn = ".", layer = "cp.states", morphToESRI = T, driver = "ESRI Shapefile")

## major cities; a point file
   cp.cities <- readOGR(".", layer = "COP_Major_Cities_pt")

## NHD water bodies; select if >50 km sq; arbitrary
   water <- readOGR(dsn = ".", layer = "COP_NHD_Waterbodies_poly")
   names(water)  # all attributes
   head(levels(water$GNIS_Name), 20)  # GNIS_Name==water body names; 1st 20 
   cp.waterLG <- water[water$AreaSqKm > 50 & !is.na(water$AreaSqKm), ]  # extract 'large' water

## NHD streams and rivers - all flow lines; a line file
   hohflow <- readOGR(dsn = ".", layer = "COP_NHD_Flowlines_line")
   names(hohflow)  # all attribute names
   head(levels(hohflow$GNIS_Name), 20)  # examine some names
## create list of unique names and use to subset rivers
   hohflow.nm <- unique(hohflow$GNIS_Name)  # list of values in column GNIS_Name
   hohflow.rv <- hohflow.nm[grep("River", hohflow.nm)]  # select GNIS_Name w/'River' only
## only condition 'River' kept
   cp.rivers <- hohflow[hohflow$GNIS_Name %in% hohflow.rv & !is.na(hohflow$GNIS_Name), ]  

## plot study area
##   NOTE: some understanding of how R plots needed
##   source .../r_code/plot_graphmargins.r; examine if uncertain about R plots
##     key elements: shows R DEFAULTS as oma (blue), mar (green), plot area (red)
##     margins read as: c(bottom,left,top,right)
##   keep or adjust or eliminate defaults as desired
##     NOTE: defaults influence placement of inset; details below
   source(paste(path.root, "/r_code/module2/graphR_margins.r", sep = ""))

## NOT RUN; some plot dimensions 
   #dev.new(width = 3.5, height = 3.5)  # basic 1-column journal format; square plot
## NOT RUN; some margin options
   #par(oma = c(1, 1, 1, 1), mar = c(2, 2, 2, 1)) # set both oma & mar together
   #par(oma = c(0, 0, 0, 0))  # turn off oma
   par(mar = c(0, 0, 0, 0))  # turn off mar; my personal default for study area maps

## plot study area w/states cropped to extent of study region
   plot(crop(cp.states, cp.region), col = "grey95")
## add rivers
   plot(cp.rivers, col = "blue", add = T)
## add water bodies
   plot(cp.waterLG, col = "blue", border = "blue", add = T)
## add cities
   plot(cp.cities, pch = 20, cex = 2, add = T)
## place city names w/in cp.region plot
##   NOTE pos=c(4,2,3,2) in text() for names placement as (right,left,top,left), respectively
##   city names sequence for placement from:
##     levels(cp.cities$NAME) & order(cp.cities$NAME)
##     NOTE: !! NOT !! alphabetic; match order & levels for correct sequence
   levels(cp.cities$NAME)  # factor levels alphabetized
   order(cp.cities$NAME)  # internal R order of factor levels; not always same as levels order
   text(coordinates(cp.cities), labels = as.character(cp.cities$NAME), 
        cex = 1.25, pos = c(4, 2, 3, 2), col = "black")

## legend call to mix line & dot symbols; NOTE -1 indicates a "blank" value
   legend("bottomleft", legend = c("Cities", "Rivers"), cex = 1.25, bty = "n", 
          inset = 0.04, lty = c(-1, 1), pch = c(20, -1), pt.cex = 1.75, 
		  lwd = 2, col = c("black", "blue"))

## add a map scale => fxn: map.scale() package GISTools
##   NOTE: use GISTools map.scale() !! NOT !! maps map.scale()
##     have to detach(package:maps) if library(maps) loaded
##   1st convert desired map scale to projection units of spatial polygon
   cp.region  # determine map units in coord.ref as +units=; here will be m
## fxn km2m; EXAMPLE x==200 means a scale of 200 km or 200000 map units in m
   km2m <- function(x) {x * 1000}  # fxn to convert km to map units of m

## location of map scale based on map units of primary plot 
##   use extent(cp.region) to determine location
   extent(cp.region)  # returns the xmin,xmax,ymin,ymax of plot region
##   next multiply extent[xmin,ymin] by scaler to place plot
##     often requires testing diff scalers to make pretty
##   xc & yc == extent() xmin & ymin, respectively
##   len= is length; 200 is max length of scale, fxn converts to map units in m
##   ndivs= number of scale divisions
##   subdiv= label scale, 100 is scale unit in km
   map.scale(xc = 0.8 * extent(cp.region)[1], yc = 1.015 * extent(cp.region)[3], 
             len = km2m(200), ndivs = 2, subdiv = 100, "km")
## NOT RUN; scale of 0-200km w/ticks at [0,50,100,200]
   #map.scale(xc = 0.8 * extent(cp.region)[1], yc = 1.015 * extent(cp.region)[3], 
   #          len = km2m(200), ndivs = 4, subdiv = 50, "km")
			 
## add a north arrow => fxn north.arrow() package GISTools
##   as above, multiple extents for arrow placement & use km2m fxn for arrow size
   north.arrow(xb = 0.86 * extent(cp.region)[1], yb = 1.035 * extent(cp.region)[3], 
               len = km2m(5), lab = "N", col = "black")

## close out plot and set margin boundaries for inset
   box(col = "white")  # color != white (eg black) places (black) border around plot

## define inset plot with respect to entire plot area scaled from 0-1
##
##   inset is based a 1.0 x 1.0 proportion scaled to plot (red area per above)
##   seq of inset corners is (xmin,xmax,ymin,ymax)
##     thus .1 means "offset by 10% of plot region" ie from left, move .1 of 1
##     given offset of .1, xmin==.1, ymax==.9
##   size of inset is again as a proportion of 1.0 x 1.0 plot region
##     thus .2 is 20% of plot region will be filled by inset
##     given inset fill of .2, xmax==.3, ymin==.7
## (it's easier to calculate than it looks ....)

## set size of inset plot
   par(plt = c(0.05, 0.35, 0.65, 0.95), new = T) # build a plot; offset==.05, size==.3
   #par(plt = c(0.15, 0.35, 0.65, 0.85), new = T) # build a plot; offset==.15, size==.2 

## fill inset with white (or any desired color)
   polygon(c(xmin(extent(cp.states)), xmax(extent(cp.states)), 
             xmax(extent(cp.states)), xmin(extent(cp.states))), 
           c(ymin(extent(cp.states)), ymin(extent(cp.states)), 
             ymax(extent(cp.states)), ymax(extent(cp.states))), 
           col = "white")

## remind r you are plotting in the inset window; plt=c() MUST be identical to plt=c() above
   par(plt = c(0.05, 0.35, 0.65, 0.95), new = T)  # build a plot; offset==.05, size==.3
   #par(plt = c(0.15, 0.35, 0.65, 0.85), new = T) # build a plot; offset==.15, size==.2 

## add inset layers
   plot(cp.states)
   plot(cp.region, col = "grey95", add = T)
   plot(cp.states, add = T)
   #box() # would add border to inset if desired

## save plot if desired; pdf your best bet format
   #savePlot(filename = "outdata/cp_studyfig.pdf", type = "pdf")
####
######## END Module 2.6 ########





 
