# syntax=docker/dockerfile:1
FROM python:3.6
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /code

COPY requirements.txt /code/
RUN pip install --upgrade pip 
RUN pip install -r requirements.txt
COPY . /code/

ENV DJANGO_SUPERUSER_PASSWORD=password
ENV DJANGO_SUPERUSER_USERNAME=ankitnayan
ENV DJANGO_SUPERUSER_EMAIL=ankit@signoz.io

RUN python manage.py migrate
RUN python manage.py collectstatic --noinput
RUN python manage.py createsuperuser --no-input


RUN opentelemetry-bootstrap --action=install
EXPOSE 8000

CMD ['opentelemetry-instrument', 'gunicorn', 'mysite.wsgi', '-c', 'gunicorn.config.py', '--workers', '2', '--threads', '4', '--reload']
