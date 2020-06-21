#!/usr/bin/env python

from faker import Faker
from confluent_kafka import Producer
import socket
import json
import sys, getopt, time, os
import argparse

def main():
    # Display the program start time
    print('-' * 40)
    print(os.path.basename(sys.argv[0]) + " started at ", time.ctime())
    print('-' * 40)

    print('Number of arguments          :', len(sys.argv))
    print('Argument List:', str(sys.argv))

    parser = argparse.ArgumentParser(description="""
    This script generates sample data for specified kafka topic. 
    """)
    parser.add_argument("--bootstrap_servers", help="Bootstrap servers", required=True)
    parser.add_argument("--topic_name", help="Topic name", required=True)
    parser.add_argument("--no_of_records", help="Number of records", type=int, required=True)

    args = parser.parse_args()

    global bootstrap_servers
    bootstrap_servers = args.bootstrap_servers

    global topic_name
    topic_name = args.topic_name

    global no_of_records
    no_of_records = args.no_of_records

    print("Bootstrap servers            : " + bootstrap_servers)
    print("Topic name                   : " + topic_name)
    print("Number of records            : " + str(no_of_records))

class DatetimeEncoder(json.JSONEncoder):
    def default(self, obj):
        try:
            return super(DatetimeEncoder, obj).default(obj)
        except TypeError:
            return str(obj)

def faker_datagen():
    conf = {'bootstrap.servers': bootstrap_servers,
        'client.id': socket.gethostname()}
        
    producer = Producer(conf)
    faker = Faker()
    count = 0
    while count < no_of_records:
        profile = faker.simple_profile()
        #print(profile)
        #print(profile['username'])
        message = json.dumps(profile, cls=DatetimeEncoder)
        key=str(profile['username'])
        producer.produce(topic=topic_name, value=message, key=key)
        producer.flush()
        count += 1
        
if __name__ == "__main__":
    main()
    faker_datagen()
    sys.exit()
