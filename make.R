library(sf)
library(jsonlite)
library(tidyverse)
library(purrr)
library(geojsonio)
library(geojsonsf)
#####################################################
## 1. read in the file
#####################################################
d <- read_csv("Dam.csv", col_types = cols(.default = "c")) #%>% select(-fips,-state_uri)
#####################################################
## 2. Create a unique identifier 
#####################################################

## 2.1 # this is just for demonstration purposes
# probably a better way that is persistent over time

d$hydrosource_id <- 1:nrow(d) 

## 2.2 Make a URI based on the unique identifier for the geoconnex system
# This is "https://geoconnex.us/<organizational namespace>/<other>/<path>/<pattern>/<identifier>

d$uri <- paste0("https://geoconnex.us/ornl/hydrosource/dams/",
                d$hydrosource_id)

d$dam_nam <- gsub('"',"",d$dam_name)
######################################################
## 3. Reference other geoconnex resources
######################################################

## 3.1 States
# Use FIPS codes for States
  
  # read source file
  fips <- read_csv("https://raw.githubusercontent.com/internetofwater/fips-codes/master/state_fips_master.csv")
  
  # take only state abbr and fips
  fips <- select(fips,state_abbr,fips)
  
  # convert fips to 2-digit code with leading 0s for 1-digit ones
  fips$fips <- formatC(fips$fips, 
                       width = 2,
                       format = "fg",
                       flag = "0")
  
  # create geoconnex ids for states to merge in
  fips$state_uri <- paste0("https://geoconnex.us/ref/states/",fips$fips)
  
  
  # merge in FIPS
  d <- left_join(d,fips,by=c("state"="state_abbr"))

## 3.2 HUC12
# use geoconnex codes for huc12
  
  # NOTE: some of these HUCs are just scientific notation, or 8 digits, or missing leading 0s. Double check!
  
  # add leading 0s for 11-digit hucs
  d$huc12<- formatC(as.numeric(d$huc), 
                       width = 12,
                       format = "fg",
                       flag = "0")
  
  
  d$huc12_uri <- paste0("https://geoconnex.us/nhdplusv2/huc12/",d$huc12)

## 3.3 comid
# use geoconnex codes for comid
  
  d$comid <- NA # NOTE: No COMID, add if available
  d$comid_uri <- paste0("https://geoconnex.us/nhdplusv2/comid/",d$comid)
  

#  write_csv(d,"dams.csv",append=FALSE)
  
######################################################
## 4. Convert to geojson
######################################################
  
# 4.1 Convert to simple features
g <- st_as_sf(d,coords=c("longitude","latitude")) 
  
# 4.2 encode identifiers in different datasets
# id_eha
j <- g
j$`@type` <- "schema:PropertyValue"
j$`schema:PropertyID` = "eha_ptid"
j$`schema:value` <- j$eha_ptid

j <- j %>% st_drop_geometry() %>% select(`@type`,`schema:PropertyID`,`schema:value`)

id_eha <- j %>% mutate(id_eha = pmap(.,
                                         ~toJSON(list("@type"="schema:PropertyValue",
                                              "schema:PropertyID" = "eha_ptid",
                                              "schema:value" = ..3),
                                              auto_unbox=TRUE))) %>% 
  select(id_eha)

# id_hillari
j <- g
j$`@type` <- "schema:PropertyValue"
j$`schema:PropertyID` = "hilarriid"
j$`schema:value` <- j$hilarriid

j <- j %>% st_drop_geometry() %>% select(`@type`,`schema:PropertyID`,`schema:value`)

id_hilarri <- j %>% mutate(id_hilarri = pmap(.,
                                     ~toJSON(list("@type"="schema:PropertyValue",
                                                  "schema:PropertyID" = "hilarriid",
                                                  "schema:value" = ..3),
                                             auto_unbox=TRUE))) %>% 
  select(id_hilarri)


# id_fcdocket
j <- g
j$`@type` <- "schema:PropertyValue"
j$`schema:PropertyID` = "fcdocket"
j$`schema:value` <- j$fcdocket

j <- j %>% st_drop_geometry() %>% select(`@type`,`schema:PropertyID`,`schema:value`)

id_fcdocket <- j %>% mutate(id_fcdocket = pmap(.,
                                             ~toJSON(list("@type"="schema:PropertyValue",
                                                          "schema:PropertyID" = "fcdocket",
                                                          "schema:value" = ..3),
                                                     auto_unbox=TRUE))) %>% 
  select(id_fcdocket)


# id_nid
j <- g
j$`@type` <- "schema:PropertyValue"
j$`schema:PropertyID` = "nidid"
j$`schema:value` <- j$nidid

j <- j %>% st_drop_geometry() %>% select(`@type`,`schema:PropertyID`,`schema:value`)

id_nid <- j %>% mutate(id_nid = pmap(.,
                                               ~toJSON(list("@type"="schema:PropertyValue",
                                                            "schema:PropertyID" = "nidid",
                                                            "schema:value" = ..3),
                                                       auto_unbox=TRUE))) %>% 
  select(id_nid)

# 4.3 add all encoded ids

g <- cbind(g,id_eha,id_hilarri,id_fcdocket,id_nid)


#############################################################
# 5 write geojson file
###########################################################

# 5.1 add final geoconnex types
g$hyf = "http://www.opengeospatial.org/standards/waterml2/hy_features/HY_HydroLocation"
g$hyf_type = "http://www.opengeospatial.org/standards/waterml2/hy_features/dam"
g$dam_name <- gsub("\"","'",g$dam_name)
# write file
#test <- g[573,]
#geojson_write(test,file="test.geojson")

geojson_write(g,file="dams.geojson")

x <- readLines("dams.geojson")
x <- gsub('["','',x,fixed=TRUE)
x <- gsub('"]','',x,fixed=TRUE)
x <- gsub('\\','',x,fixed=TRUE)

# clean internal quotes and brackets "[ ]"
unlink("dams.geojson")
writeLines(x, con="dams.geojson")



#############################################################
# 6 Make PIDS
###########################################################


pids <- select(d,uri,hydrosource_id)
pids <- pids %>% 
  mutate(id = uri,
         target = paste0("http://localhost:5000/collections/dams/items/",hydrosource_id),
         creator = "email address",
         description = "dam in ORNL Hydrosource datasets"
         ) %>% 
  select(id, target, creator, description)

write_csv(pids,"dams_pids.csv", append=FALSE)
