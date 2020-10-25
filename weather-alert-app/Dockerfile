FROM python:3

COPY . /usr/src/
WORKDIR /usr/src/

RUN apt-get update && apt-get install -y \
    iputils-ping \
    iproute2 \
    curl \
	dos2unix \
	netcat \
	net-tools \
 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/edenhill/librdkafka.git
RUN pwd
RUN cd /usr/src/librdkafka/ && ./configure --install-deps && make && make install && ldconfig

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

#ENV bootstrap_servers localhost:9092
#ENV topic_name weather.alert.app.source
#ENV schema_registry_url localhost:8081
#ENV lat 38.883530
#ENV lon -94.818240

#CMD ["sh", "-c", "python /usr/src/app/weather-alert-app.py --bootstrap_servers $bootstrap_servers --topic_name $topic_name --schema_registry_url $schema_registry_url --lat $lat --lon $lon"]
