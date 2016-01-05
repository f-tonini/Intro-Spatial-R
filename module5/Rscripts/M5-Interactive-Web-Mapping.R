## ----load packages, message = FALSE--------------------------------------
library(rgdal)   #for reading/writing geo files
library(rgeos)   #for simplification
library(sp)
library(plyr)
library(dplyr)
library(leafletR)
library(maptools)
library(RColorBrewer)
library(Quandl)
library(reshape2)

## ----load devtools, message = FALSE--------------------------------------
library(devtools)
## The R packages rCharts and rMaps are not available on CRAN yet.
## Run the following code to install from Github repo prior to loading the libraries:

## install_github('ramnathv/rCharts')
## install_github('ramnathv/rMaps')
library(rCharts)
library(rMaps)

## ----set working directory, eval=FALSE-----------------------------------
## setwd("D:/Google Drive/IALE2015/r_code/module5")
## #setwd("path_to_your_folder")   # for Windows users
setwd("~/Documents/Intro-Spatial-R/module5") # ~ for Mac users

## ----read shapefiles-----------------------------------------------------
deer_unit <- readOGR(dsn = "data", layer = "deerrange_UT") # Game management units

## ----summary shapefile data----------------------------------------------
summary(deer_unit@data)
names(deer_unit) # The attribute data names
class(deer_unit)

## ----calculate new field-------------------------------------------------
deer_unit$tot_deer_elk <- rowSums(cbind(deer_unit$DEER, deer_unit$ELK))
summary(deer_unit@data)

## ----simplify shapefile--------------------------------------------------
#save the data slot
deer_unit_sub <- deer_unit@data[,c("UName", "UNum", "AREA_km2", "tot_deer_elk")]
#simplification yields a SpatialPolygons class
deer_unit <- gSimplify(deer_unit, tol=0.01, topologyPreserve=TRUE)
class(deer_unit)

#to write to geojson we need a SpatialPolygonsDataFrame
deer_unit <- SpatialPolygonsDataFrame(deer_unit, data=deer_unit_sub)
class(deer_unit)
head(deer_unit@data)

## ----write GeoJSON-------------------------------------------------------
# write data to GeoJSON
dir <- paste(getwd(), "DeerElkGeoJson", sep="/")
writeOGR(deer_unit, dir, layer="DeerElk", driver="GeoJSON")
# a GeoJSON datasource is translated to single OGRLayer object with pre-defined name OGRGeoJSON"
ogrListLayers(paste(getwd(), "DeerElkGeoJson", sep="/"))
ogrInfo(paste(getwd(), "DeerElkGeoJson", sep="/"), "OGRGeoJSON")

## ----create cuts---------------------------------------------------------
cuts <- round(quantile(deer_unit$tot_deer_elk, probs = seq(0, 1, 0.20), na.rm = FALSE), 0)

## ----popup fields--------------------------------------------------------
popup <- c("UName", "UNum", "AREA_km2", "tot_deer_elk")

## ----graduated style-----------------------------------------------------
sty <- styleGrad(prop="tot_deer_elk", breaks=cuts, closure="left", style.par="col", 
                 style.val=rev(heat.colors(5)), leg="Deer & Elk Population", lwd=1)

## ----create map, message=FALSE-------------------------------------------
map <- leaflet(data=dir, dest=getwd(), style=sty,
             title="DeerElk", base.map="osm",
             incl.data=TRUE,  popup=popup)

## ----browse map----------------------------------------------------------
browseURL(map)

## ----get data------------------------------------------------------------
# read in data table 
tree_dat <- read.csv("./data/plots_umca_infection.csv", header=T)
# read plot locations shapefile
plots <- readOGR(dsn='./data', layer='plot_202_latlon')
# using the `dplyr` package by Hadley Wickham, let's subset data for year 2012 only.
tree_dat_2012 <- tree_dat %>%
     select(plot, year, tot_bay) %>%
     group_by(plot) %>%
     filter(year == 2012)
tree_dat_2012

## ----add latlon----------------------------------------------------------
name_match <- match(tree_dat_2012$plot, plots@data$PLOT_ID)
tree_dat_2012 <- cbind(plots@data[name_match, c("POINT_Y","POINT_X")], tree_dat_2012)
names(tree_dat_2012)[1:2] <- c("lat", "lon") 
# get rid of the year and plot variables.
tree_dat_2012 <- tree_dat_2012[ ,!names(tree_dat_2012) %in% c("year","plot")]
head(tree_dat_2012)

## ----leaflet_map, message=FALSE------------------------------------------
# create a new leaflet map instance
Lmap <- Leaflet$new()
# set the view and zoom to the desired study area. Let's center it on our mean lat-lon coordinates
Lmap$setView(c(mean(tree_dat_2012$lat), mean(tree_dat_2012$lon)), 10)
# add a basemap using OSM 
Lmap$tileLayer(provider = "MapQuestOpen.OSM")
# plot the study area (.html file is created locally)
Lmap

## ----convert to JSON-----------------------------------------------------
tree_dat <- toJSONArray2(na.omit(tree_dat_2012), json = F, names = F)
# let's print out the first two elements of the JSON file
cat(rjson::toJSON(tree_dat[1:2]), '\n')

## ----heat_map, message=FALSE---------------------------------------------
# add leaflet-heat plugin. Thanks to Vladimir Agafonkin
Lmap$addAssets(jshead = c(
  "http://leaflet.github.io/Leaflet.heat/dist/leaflet-heat.js"
))

# add javascript to modify underlying chart
Lmap$setTemplate(afterScript = sprintf("
<script>
  var addressPoints = %s
  var heat = L.heatLayer(addressPoints).addTo(map)           
</script>
", rjson::toJSON(tree_dat)
))
# plot heat map of UMCA tree abundance (.html file is created locally)
Lmap

## ----get Quandl data-----------------------------------------------------
rbData = Quandl("FBI_UCR/USCRIME_TYPE_BURGLARIES")
rbData[1:10, 1:5]

## ----reshape data--------------------------------------------------------
datm <- melt(rbData, 'Year', 
  variable.name = 'State',
  value.name = 'Crime'
)
datm <- subset(na.omit(datm), 
  !(State %in% c("United States", "District of Columbia"))
)
head(datm)

## ----discretize data-----------------------------------------------------
datm2 <- transform(datm,
  State = state.abb[match(as.character(State), state.name)],
  fillKey = cut(Crime, quantile(Crime, seq(0, 1, 1/4)), labels = LETTERS[1:4]),
  Year = as.numeric(substr(Year, 1, 4))
)

## ----fill color----------------------------------------------------------
fills = setNames(
  c(RColorBrewer::brewer.pal(4, 'OrRd'), 'white'),
  c(LETTERS[1:4], 'defaultFill')
)

## ----convert data frame--------------------------------------------------
dat2 <- dlply(na.omit(datm2), "Year", function(x){
  y = toJSONArray(x, json = F)
  names(y) = lapply(y, '[[', 'State')
  return(y)
})
names(dat2)
#dat2[["1960"]] to inspect a list element

## ----simple choro map----------------------------------------------------
options(rcharts.cdn = TRUE)
map <- Datamaps$new()
map$set(
  dom = 'chart_1',
  scope = 'usa',
  fills = fills,
  data = dat2[["1980"]],
  legend = TRUE,
  labels = TRUE
)
map

## ----dynamic choro map, echo=-1------------------------------------------
source('Rscripts/ichoropleth.R')
map2 <- ichoropleth(Crime ~ State,
  data = datm2[,1:3],
  pal = 'OrRd', # color ramp
  ncuts = 4,  # quartiles
  animate = 'Year'
)
map2

