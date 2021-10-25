FROM geopython/pygeoapi:latest
#pygeoapi last updated 2021-10-15

#Add data directory
RUN mkdir /data

#HU02 last updated 2021-06-04 15:36:00 UTC-5
ADD https://www.hydroshare.org/resource/4a22e88e689949afa1cf71ae009eaf1b/data/contents/hu02.gpkg /data/

COPY ./pygeoapi.config.yml /pygeoapi/local.config.yml

