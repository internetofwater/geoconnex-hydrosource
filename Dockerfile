FROM geopython/pygeoapi:latest
#pygeoapi last updated 2021-10-15

#Add data directory
RUN mkdir /data

#dams last updated 2021-10-25 15:36:00 UTC-5
ADD https://raw.githubusercontent.com/internetofwater/geoconnex-hydrosource/main/dams.geojson /data/

COPY ./pygeoapi.config.yml /pygeoapi/local.config.yml

