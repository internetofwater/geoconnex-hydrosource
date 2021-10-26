# deploy

1. Clone repository
```
git clone https://github.com/internetofwater/geoconnex-hydrosource
```

2. Change `url` in line 36 of `pygeoapi.config.yml` to desired host address

3. Deploy on host machine

```
docker-compose up -d --build
```

pygeoapi is running at port 5000. Modify docker-compose as apprioriate to expose different port and/or reverse proxy in front to direct public http(s) traffic to server listening at port 5000 behind firewall.
