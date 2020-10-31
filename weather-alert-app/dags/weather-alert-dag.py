from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta
from airflow.operators.docker_operator import DockerOperator

default_args = {
        'owner'                 : 'airflow',
        'description'           : 'Runs the python module to source weather data from openweather',
        'depend_on_past'        : False,
        'start_date'            : datetime(2020, 10, 29),
        'email_on_failure'      : False,
        'email_on_retry'        : False,
        'retries'               : 1,
        'retry_delay'           : timedelta(minutes=5),
        'schedule_interval'     : '@hourly'
}

with DAG('weather-alert-source-data', default_args=default_args, schedule_interval='@hourly', catchup=False) as dag:
        
        t1 = BashOperator(
                task_id='print_start_time',
                bash_command='echo `date "+%Y-%m-%d%H:%M:%S"` "- Airflow Task Started"'
        )
        
        t2 = DockerOperator(
                task_id='docker_command',
                image='centos:latest',
                api_version='auto',
                auto_remove=True,
                command="/bin/sleep 30",
                docker_url="unix://var/run/docker.sock",
                network_mode="bridge"
        )
        
        t3 = BashOperator(
                task_id='print_end_time',
                bash_command='echo `date "+%Y-%m-%d%H:%M:%S"` "- Airflow Task Finished"'
        )

        t1 >> t2 >> t3