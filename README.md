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
