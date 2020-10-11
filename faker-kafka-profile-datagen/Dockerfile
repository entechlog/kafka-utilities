FROM python:3

COPY . /usr/src/
WORKDIR /usr/src/

# un-comment only if the confluent-kafka install fails
#RUN git clone https://github.com/edenhill/librdkafka.git
#RUN pwd
#RUN cd /usr/src/librdkafka/ && ./configure --install-deps && make && make install && ldconfig

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

RUN apt-get update && apt-get install -y \
    iputils-ping \
    iproute2 \
    curl \
	dos2unix \
	netcat \
	net-tools \
 && rm -rf /var/lib/apt/lists/*

COPY . .

ENV bootstrap_servers localhost:9092
ENV topic_name datagen.user.profile 
ENV no_of_records 1

CMD ["sh", "-c", "python /usr/src/app/faker-kafka-profile-datagen.py --bootstrap_servers $bootstrap_servers --topic_name $topic_name --no_of_records $no_of_records"]
