# deploy

1. Clone repository
```
git clone https://github.com/internetofwater/geoconnex-hydrosource
cd pygeoapi
```

2. Change `url` in line 36 of `pygeoapi.config.yml` to desired host address

3. Deploy on host machine

```
docker-compose up -d --build
```

pygeoapi is running at port 5000. Modify docker-compose as apprioriate to expose different port and/or reverse proxy in front to direct public http(s) traffic to server listening at port 5000 behind firewall.

# Outstanding items

1. Decide domain for hydrosource pygeoapi e.g. https://features.hydrosource.ornl.gov
2. Decide what particular cross-dataset collections should be published. THe current one is some kind of combination of powerplants and dams. Perhaps there should be powerplants, dams, lakes, and stream reaches
3. Decide on `hydrosource_id` scheme to implement for each collection across Hydrosource datasets
4. Decide on `uri` geoconnex identifier scheme for each collection eg https://geoconnex.us/ornl/hydrosource/dams/<hydrosouce_id>
5. Host these collections as their own hydrosource dataset/resource
6. Automate the updating of these collections
7. Automate the update of the pygeoapi
