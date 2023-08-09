import os
import boto3
from moto import mock_sqs
import cleanup_handler
import pytest
@pytest.fixture(scope="function")
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"
    os.environ["AWS_DEFAULT_REGION"] = "us-east-1"

@pytest.fixture(scope="function")
def sqs(aws_credentials):
    with mock_sqs():
        yield boto3.resource("sqs", region_name="us-east-1")

@pytest.fixture(scope="function")
def sqs_client(aws_credentials):
    with mock_sqs():
        yield boto3.client("sqs", region_name="us-east-1")