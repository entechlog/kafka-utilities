# kafka-utilities

## weather-alert-app

Idea is to create telegram-bot for weather data https://www.confluent.io/blog/building-a-telegram-bot-powered-by-kafka-and-ksqldb/

```
docker build --tag entechlog/weather-alert-app .

docker images

docker run -it --rm  -e bootstrap_servers=192.168.1.8:39092 -e topic_name=weather.alert.app.source -e input_location=Marthandam,IN -e OPEN_WEATHER_API_KEY=secure entechlog/weather-alert-app
```