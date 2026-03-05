# Preparing Django app

1. `python3 manage.py migrate`
2. `python3 manage.py collectstatic`
3. `python3 manage.py createsuperuser`

# Running with SigNoz

- Create a virtual environment and activate it

```
python3 -m venv .venv
source .venv/bin/activate
```

- Install requirements

```
pip install -r requirements.txt
```

- Install instrumentation packages

```
opentelemetry-bootstrap --action=install
```

## Latest Python local testing

Use any Python environment manager (venv/pyenv/conda/poetry) with Python 3.13.

```
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Run collector with:

```
otelcol-contrib --config=<path-to-otel-collector-config.yaml>
```

## To run with gunicorn you need to add post_fork hook

1. Add a file `gunicorn.config.py` as given in this repo
2. Specify that config file when running gunicorn with `opentelemetry-instrument`

```
DJANGO_SETTINGS_MODULE=<DJANGO_APP>.settings OTEL_TRACES_EXPORTER=console,otlp OTEL_METRICS_EXPORTER=none OTEL_RESOURCE_ATTRIBUTES=service.name=<serviceName> OTEL_EXPORTER_OTLP_ENDPOINT=http://<IP OF SigNoz>:4317 OTEL_EXPORTER_OTLP_PROTOCOL=grpc opentelemetry-instrument gunicorn <DJANGO_APP>.wsgi -c gunicorn.config.py --workers 2 --threads 2
```
*specifying **DJANGO_SETTINGS_MODULE** is necessary for opentelemetry instrumentation to work*

**For this example, sample command would look like**

```
DJANGO_SETTINGS_MODULE=mysite.settings OTEL_TRACES_EXPORTER=console,otlp OTEL_METRICS_EXPORTER=none OTEL_RESOURCE_ATTRIBUTES=service.name=sample-django-app OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:4317 OTEL_EXPORTER_OTLP_PROTOCOL=grpc DEVELOPMENT_MODE=True opentelemetry-instrument gunicorn mysite.wsgi -c gunicorn.config.py --workers 2 --threads 2
```

Note: set `OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf` and port 4318 in endpoint `OTEL_EXPORTER_OTLP_ENDPOINT="http://<IP of SigNoz>:4318"` if you are using OTLP HTTP exporter.

# If want to run docker image of django app directly 
```
docker run --env \
    --env OTEL_SERVICE_NAME=djangoApp \
    --env OTEL_EXPORTER_OTLP_ENDPOINT=host.docker.internal:4317 \
    --env OTEL_EXPORTER_OTLP_PROTOCOL=grpc \
    --env DJANGO_SETTINGS_MODULE=mysite.settings \
    -p 8000:8000 \
    -t signoz/sample-django:latest opentelemetry-instrument gunicorn mysite.wsgi -c gunicorn.config.py --workers 2 --threads 2 --bind 0.0.0.0:8000
```

# If want to use docker image of django app in docker-compose
Add below service to your docker-compose
```
  django-app:
    image: "signoz/sample-django:latest"
    container_name: sample-django
    command: opentelemetry-instrument gunicorn mysite.wsgi -c gunicorn.config.py --workers 2 --threads 2 --bind 0.0.0.0:8000
    ports:
      - "8000:8000"
    environment:
    - OTEL_SERVICE_NAME=djangoApp
    - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
    - OTEL_EXPORTER_OTLP_PROTOCOL=grpc
    - DJANGO_SETTINGS_MODULE=mysite.settings
```

# Browsing the app and checking at SigNoz

1. Visit `http://localhost:8000/admin` and create a question for poll
2. Then visit the list of polls at `http://localhost:8000/polls/` and explore the polls
3. The data should be visible now in SigNoz at `http://<IP of SigNoz>:3000`
