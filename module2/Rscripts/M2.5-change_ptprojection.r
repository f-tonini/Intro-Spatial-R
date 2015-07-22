######## START MODULE 2.5 ########
#### OBJECTIVE:
####   convert points of 1 projection to other desired projection
####   this could be converted to a fxn very easily
####
#### tested on R versions 3.1.X, 3.2.X

## some needed libraries
   library(sp)      # fxns: coordinates, proj4string
   library(rgdal)   # fxns: spTransform
## some initializations
   path.root <- "~/IALE2015_gisRcourse"
   path.dat <- paste(path.root, "/data", sep = "")
   setwd(path.dat)
## some data import; [x,y] as utm zone12 (you would/should know this!)
   d1 <- read.csv("crba6RAW.csv", stringsAsFactors = F, header = T)
   str(d1)  # examine

## one source for common projections:
##   http://spatialreference.org/ ; EXAMPLE access as shown in next line
##     Home => Search => EX: "NAD83 Albers" => Click "AlbersNorthAmerican" => Click "Proj4js format"
##     returns projection string; copy & paste string, including quotes as below
##   !!!! WARNING !!!!  No hard returns allowed in projection string assignment; R won't like you
##     latlong  => "standard" lat-long in NAD83
##     utm83z12 => UTM zone12
##     aea83    => Albers Equal Area
##     wgs84    => lat-long in WGS84
##     merc     => Mercator in m
   prj.latlong <- "+proj=latlong +ellps=GRS80 +datum=NAD83 +no_defs"
   prj.utm83z12 <- "+proj=utm +zone=12 +ellps=GRS80 +datum=NAD83 +units=m +no_defs +towgs84=0,0,0"
   prj.aea <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs +towgs84=0,0,0"
   prj.wgs84 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"
   prj.merc <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"

## transform [x,y]'s of 1 projection (pts.in) to another (pts.out)
##   fxn coordinates => package sp (loaded as dependency of raster) 
##   fxn prj4string  => package sp (loaded as dependency of raster) 
##   fxn spTransform => package rgdal
## NOTE this would be a cool & handy function to write and keep
   pts.in <- d1[, c("utm_x", "utm_y")]  # subset input [x,y]
   coordinates(pts.in) <- ~utm_x + utm_y  # where x=longitude and y=latitude; input [x,y] here
   proj4string(pts.in) <- CRS(prj.utm83z12)  # input projection here
   pts.out <- as.data.frame(spTransform(pts.in, CRS(prj.wgs84)))  # output reprojected pts as dataframe
   names(pts.out) <- c("wgs84_x", "wgs84_y")  # assign names to reprojected pts
   d2 <- cbind(d1, pts.out)
   d2 <- d2[c(3, 1:2, 4:5)]  # bind & reorder
   head(d2)  # examine
   
## save file if desired
   write.csv(d2,filename = "crba6MOD.csv", row.names=F)
####
######## END MODULE 2.5 ######## 
