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

USER airflow
