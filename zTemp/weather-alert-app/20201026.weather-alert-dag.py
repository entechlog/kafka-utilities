from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta
from airflow.operators.docker_operator import DockerOperator

default_args = {
        'owner'                 : 'airflow',
        'description'           : 'Runs the python module to source weather data from openweather',
        'depend_on_past'        : False,
        'start_date'            : datetime(2020, 10, 25),
        'email_on_failure'      : False,
        'email_on_retry'        : False,
        'retries'               : 1,
        'retry_delay'           : timedelta(minutes=5),
        'schedule_interval'     : '@hourly'
}

with DAG('docker_dag', default_args=default_args, schedule_interval='@hourly', catchup=False) as dag:
        t1 = BashOperator(
                task_id='print_header',
                bash_command='echo `date "+%Y-%m-%d%H:%M:%S"` "- Airflow Task print_header"'
        )

#        t2 = DockerOperator(
#                task_id='docker_command',
#                image='entechlog/weather-alert-app',
#                network_mode='bridge',
#                api_version='auto',
#                auto_remove=True,
#                #docker_url="tcp://localhost:2375",
#                docker_url="unix://var/run/docker.sock",
#                command='python /usr/src/app/weather-alert-app.py --bootstrap_servers $BOOTSTRAP_SERVERS --topic_name $TOPIC_NAME --schema_registry_url $SCHEMA_REGISTRY_URL --lat $LAT --lon $LON --OPEN_WEATHER_API_KEY $OPEN_WEATHER_API_KEY',
#                environment={
#                        'BOOTSTRAP_SERVERS': "192.168.1.8:39092",
#                        'SCHEMA_REGISTRY_URL': "http://192.168.1.8:8081",
#                        'TOPIC_NAME': "weather.alert.app.source",
#                        'LAT': "8.28",
#                        'LON': "77.18",
#                        'OPEN_WEATHER_API_KEY': "",
#                        'network_mode': "bridge"
#                },
#                volumes=['/var/run/docker.sock:/var/run/docker.sock'],
#                dag=dag)
        
        t2 = DockerOperator(
                task_id='docker_command',
                image='centos:latest',
                api_version='auto',
                auto_remove=True,
                command="echo I AM INSIDE DOCKER",
                docker_url="unix://var/run/docker.sock",
                network_mode="bridge"
        )

        t3 = BashOperator(
                task_id='print_footer',
                bash_command='echo `date "+%Y-%m-%d%H:%M:%S"` "- Airflow Task print_footer"'
        )

        t1 >> t2 >> t3