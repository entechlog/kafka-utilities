# kafka-utilities

## weather-alert-app

Idea is to create telegram-bot for weather data https://www.confluent.io/blog/building-a-telegram-bot-powered-by-kafka-and-ksqldb/#building-telegram-bot

https://www.confluent.io/blog/build-streaming-etl-solutions-with-kafka-and-rail-data/

https://github.com/confluentinc/demo-scene/tree/master/rail-data-streaming-pipeline

https://github.com/confluentinc/demo-scene/tree/master/ksqldb-twitter

```
docker build --tag entechlog/weather-alert-app .

docker images

docker run -it --rm  -e bootstrap_servers=192.168.1.8:39092 -e 
schema_registry_url=http://192.168.1.8:8081 -e topic_name=weather.alert.app.source -e lat=38.88 -e lon=-94.82 -e OPEN_WEATHER_API_KEY=secure entechlog/weather-alert-app
```

## References
### Airflow
- https://github.com/flaviofgf/magnetis_test

### Python
- https://github.com/confluentinc/examples/blob/6.0.0-post/clients/cloud/python/producer_ccsr.py
- https://github.com/filipovskid/DRBoson/

- Create bot by sending `/newbot` to https://t.me/botfather. See https://core.telegram.org/bots for official instructions.

- Test your bot by sending a test message. To send this, you will need chat_id which can retrived by sending `/start` to https://telegram.me/userinfobot

```
curl -s -X POST https://api.telegram.org/bot<BOT ACCESS TOKEN>/sendMessage \
    -d chat_id=<CHAT ID>\
    -d text="Its raining now !!!"
```

- You can ssh into your docker by running
```
docker exec -t -i weather-alert-app /bin/bash
```

- Produce data by running
```
python weather-alert-app.py --bootstrap_servers=broker:9092 --topic_name=weather.alert.app.source --schema_registry_u
rl=http://schema-registry:8081 --lat=8.28 --lon=77.18
```

- Error and Solution 
```
2020-10-27 17:28:19.757 UTC [1] DETAIL:  The data directory was initialized by PostgreSQL version 9.6, which is not compatible with this version 13.0

docker ps -a

docker inspect -f '{{ .Mounts }}' <container-id>

docker volume ls

docker volume rm <volume-name>

docker-compose down --volumes

```


docker-compose up --remove-orphans -d --build

