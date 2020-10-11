#!/usr/bin/env python

# importing the required library 
from confluent_kafka import Producer
import requests
import os, sys, time
import argparse
import json
import socket

def main():
    # Display the program start time
    print('-' * 40)
    print((os.path.basename(sys.argv[0])).split('.')[0] + " started at ", time.ctime())
    print('-' * 40)
    
def parse_input():

    print('Number of arguments          :', len(sys.argv))

    # Uncomment only to debug
    # print('Argument List:', str(sys.argv))

    parser = argparse.ArgumentParser(description="""
    Script writes weather data to kafka topic. 
    """)

    parser.add_argument("--bootstrap_servers", help="Bootstrap servers", required=True)
    parser.add_argument("--topic_name", help="Topic name", required=True)
    parser.add_argument("--input_location", help="Number of records", required=True)
    
    args = parser.parse_args()

    global bootstrap_servers
    bootstrap_servers = args.bootstrap_servers

    global topic_name
    topic_name = args.topic_name

    global input_location
    input_location = args.input_location

    print("Bootstrap servers            : " + bootstrap_servers)
    print("Topic name                   : " + topic_name)
    print("Location                     : " + input_location)

    # api-endpoint 
    URL = "http://api.openweathermap.org/data/2.5/weather"
    
    # get environment variables
    OPEN_WEATHER_API_KEY = os.environ.get("OPEN_WEATHER_API_KEY")
    
    # location given here 
    location = input_location
    units = "imperial"
    
    # defining a params dict for the parameters to be sent to the API 
    PARAMS = {'q':location,'APPID':OPEN_WEATHER_API_KEY,'units':units} 

    # Call weather API
    call_weather_api(URL, PARAMS)

def call_weather_api(URL, PARAMS):    
    # sending get request and saving the response as response object 
    try:
        json_data = requests.get(url = URL, params = PARAMS, timeout=3)
        json_data.raise_for_status()
        process_data(json_data)
    except requests.exceptions.HTTPError as errh:
        print ("Http Error:",errh)
    except requests.exceptions.ConnectionError as errc:
        print ("Error Connecting:",errc)
    except requests.exceptions.Timeout as errt:
        print ("Timeout Error:",errt)
    except requests.exceptions.RequestException as err:
        print ("OOps: Something Else",err)

class DatetimeEncoder(json.JSONEncoder):
    def default(self, obj):
        try:
            return super(DatetimeEncoder, obj).default(obj)
        except TypeError:
            return str(obj)

def process_data(json_data):
    # extracting data in json format 
    data = json_data.json() 
    
    # extract weather data
    timestamp = data['dt']
    name = data['name']
    latitude = data['coord']['lon']
    longitude = data['coord']['lat']
    weather = data['weather'][0]['description'] 
    temperature = data['main']['temp']
    
    # printing the output 
    print("Timestamp                    : " + str(timestamp))
    print("Location Name                : " + name)
    print("Latitude                     : " + str(latitude))
    print("Longitude                    : " + str(longitude))
    print("Weather                      : " + weather)
    print("Temperature                  : " + str(temperature))
    
    # write data to kafka
    write_to_kafka(bootstrap_servers, topic_name, data)

def write_to_kafka(bootstrap_servers, topic_name, data):
    conf = {'bootstrap.servers': bootstrap_servers,
        'client.id': socket.gethostname()}
        
    producer = Producer(conf)
    message = json.dumps(data, cls=DatetimeEncoder)
    key=str(data['name'])
    producer.produce(topic=topic_name, value=message, key=key)
    producer.flush()

def exit_module():
    # Display the program end time
    print('-' * 40)
    print((os.path.basename(sys.argv[0])).split('.')[0] + " finished at ", time.ctime())
    print('-' * 40)

if __name__ == "__main__":
    main()
    parse_input()
    exit_module()
    sys.exit()
