import os

def _get_boolean(env_name: str, fallback: str) -> bool:
    return os.environ.get(env_name, fallback).lower() in ("true", "t", "1")

MONITOR_SLEEP_SECS = float(os.environ.get("MONITOR_SLEEP_SECS", 30))

# AWS
REGION = os.environ.get("AWS_REGION", "eu-west-1")
INCOMING_QUEUE = os.environ.get("INCOMING_QUEUE")
COMPLETED_TOPIC_ARN = os.environ.get("COMPLETED_TOPIC_ARN")

# LocalStack
LOCALSTACK = _get_boolean("LOCALSTACK", "False")
LOCALSTACK_ADDRESS = os.environ.get("LOCALSTACK_ADDRESS", "http://localhost:4566")

# varnish
VARNISH_ADDRESS = os.environ.get("VARNISH_ADDRESS", "http://localhost:65345")