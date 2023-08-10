import os
import pytest
import requests_mock

import boto3
from time import sleep
from threading import Thread
from moto import mock_sqs
from unittest.mock import patch
import cleanup_handler
import mock
import json
from app.signal_handler import SignalHandler
from threading import Thread

@mock_sqs
def test_write_message_valid(sqs):
    "Test the start_monitoring_queue method with a valid message"
    # Arrange
    name = 'test-delete-notifications'
    queue = sqs.create_queue(QueueName=name)
    cleanup_handler.INCOMING_QUEUE = name
    cleanup_handler.MONITOR_SLEEP_SECS = 1
    with open('Json/FullRequest.json', 'r') as file:
        data = file.read().replace('\n', '')
    queue.send_message(QueueUrl=queue.url, MessageBody=(data))
    signal_handler = SignalHandler()

    # Act 
    t = Thread(target=cleanup_handler.start_monitoring_queue, args=(sqs, signal_handler,))
    t.start()
    # wait for messages to be handled
    sleep(2)

    # Assert
    sqs_messages = queue.receive_messages()
    assert len(sqs_messages) == 0, "queue should have no messages"

    t.join(0.1)

def test_receive_message_bans():
    "Test the receive_message method with a valid message"
    # Arrange
    with open('Json/FullRequest.json', 'r') as file:
        data = file.read().replace('\n', '')

    sqs_mock_message = mock.Mock()
    sqs_mock_message.body = data

    with requests_mock.Mocker() as mo:
        mo.request("BAN", url="http://localhost/26/18/54378677")

        # Act
        response = cleanup_handler._handle_message(sqs_mock_message)

    # Assert
    assert response == True, "response should be a success"

def test_receive_message_bans_fail():
    "Test the receive_message method with a valid message"
    # Arrange
    with open('Json/FullRequest.json', 'r') as file:
        data = file.read().replace('\n', '')

    sqs_mock_message = mock.Mock()
    sqs_mock_message.body = data

    with requests_mock.Mocker() as mo:
        mo.request("BAN", url="http://localhost/26/18/54378677", status_code=400)

        # Act
        response = cleanup_handler._handle_message(sqs_mock_message)

    # Assert
    assert response == False, "response should be a failure"