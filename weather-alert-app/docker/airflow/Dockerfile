ARG AIRFLOW_VERSION_TAG

FROM apache/airflow:${AIRFLOW_VERSION_TAG}

# https://airflow.readthedocs.io/en/latest/production-deployment.html
# https://airflow.apache.org/docs/stable/installation.html

USER root
RUN apt-get update \
 && pip install --upgrade pip \
 && apt-get install -y \
    gcc \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Create empty file for docker.sock to set required owner and group
# RUN touch /var/run/docker.sock
# RUN chown airflow:airflow /var/run/docker.sock
# VOLUME /var/run/docker.sock

USER airflow
