from opentelemetry import trace


def post_fork(server, worker):
    server.log.info("Worker spawned (pid: %s)", worker.pid)

    # create span to see if the configuration works or still emits unauthenticated transient error!
    tracer = trace.get_tracer("sample-django-app")

    with tracer.start_as_current_span("manual-from-gunicorn") as span:
        print("span!!! inside gunicorn fork", span)
        span.set_attribute("key", "value")
