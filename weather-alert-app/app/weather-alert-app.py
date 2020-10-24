#!/usr/bin/env python

# importing the required library 
from confluent_kafka import Producer
import requests
import os, sys, time
import argparse
import json
import socket

def header_footer(process):
    # Display the program start time
    print('-' * 40)
    print((os.path.basename(sys.argv[0])).split('.')[0], process, " at ", time.ctime())
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
    parser.add_argument("--lat", help="latitude", required=True)
    parser.add_argument("--lon", help="longitude", required=True)
    
    args = parser.parse_args()

    bootstrap_servers = args.bootstrap_servers
    topic_name = args.topic_name
    lat = args.lat
    lon = args.lon

    print("Bootstrap servers            : " + bootstrap_servers)
    print("Topic name                   : " + topic_name)
    print("Latitude                     : " + lat)
    print("Longitude                    : " + lon)

    return bootstrap_servers, topic_name, lat, lon

def call_weather_api(URL, PARAMS):    
    # sending get request and saving the response as response object 
    try:
        json_data = requests.get(url = URL, params = PARAMS, timeout=3)
        json_data.raise_for_status()
        process_data(json_data)
        return json_data
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
    timestamp = data['current']['dt']
    try:
        name = data['name']
    except:
        name = ""
    latitude = data['lat']
    longitude = data['lon']
    weather = data['current']['weather'][0]['description'] 
    temperature = data['current']['temp']
    
    # printing the output 
    print("Timestamp                    : " + str(timestamp))
    print("Location Name                : " + name)
    print("Latitude                     : " + str(latitude))
    print("Longitude                    : " + str(longitude))
    print("Weather                      : " + weather)
    print("Temperature                  : " + str(temperature))
    
def write_to_kafka(bootstrap_servers, topic_name, data):
    conf = {'bootstrap.servers': bootstrap_servers,
        'client.id': socket.gethostname()}
        
    producer = Producer(conf)
    message = json.dumps(data, cls=DatetimeEncoder)
    key=str(data['lat']) + str(data['lon'])
    producer.produce(topic=topic_name, value=message, key=key)
    producer.flush()

if __name__ == "__main__":
    
    # Print the header
    header_footer("started")

    # Parse the input
    bootstrap_servers, topic_name, lat, lon = parse_input()
    
    # api-endpoint 
    URL = "https://api.openweathermap.org/data/2.5/onecall"

    # get environment variables
    OPEN_WEATHER_API_KEY = os.environ.get("OPEN_WEATHER_API_KEY")

    # Prepare inputs for weather api call
    units = "imperial"    
    
    # defining a params dict for the parameters to be sent to the API 
    PARAMS = {'lat':lat,'lon':lon,'exclude':"minutely,hourly",'APPID':OPEN_WEATHER_API_KEY,'units':units}

    # Call weather API
    data = call_weather_api(URL, PARAMS)

    # write data to kafka
    if data is not None:
        write_to_kafka(bootstrap_servers, topic_name, data.json())

    # Print the footer
    header_footer("finished")

    sys.exit()
