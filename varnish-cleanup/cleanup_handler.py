import json
import traceback
import time
import requests

from logzero import logger
from app.aws_factory import get_aws_resource
from app.settings import INCOMING_QUEUE, MONITOR_SLEEP_SECS, VARNISH_ADDRESS
from app.signal_handler import SignalHandler


def start_monitoring():
    sqs = get_aws_resource("sqs")
    signal_handler = SignalHandler()
    start_monitoring_queue(sqs, signal_handler)


def start_monitoring_queue(sqs, signal_handler):
    incoming_queue = sqs.get_queue_by_name(QueueName=INCOMING_QUEUE)

    logger.info(f"starting monitoring queue '{INCOMING_QUEUE}'")

    try:
        while not signal_handler.cancellation_requested():
            message_received = False
            for message in _get_messages_from_queue(incoming_queue):
                if message and not signal_handler.cancellation_requested():
                    message_received = True
                    try:
                        if _handle_message(message):
                            message.delete()
                    except Exception:
                        e = traceback.format_exc()
                        logger.error(f"Error processing message: {e}")
                    else:
                        message_received = False

            if not message_received and not signal_handler.cancellation_requested():
                time.sleep(MONITOR_SLEEP_SECS)
    except Exception as e:
        logger.error(f"Error getting messages: {e}")
        raise e

    logger.info(f"stopped monitoring queue '{INCOMING_QUEUE}'...")


def _get_messages_from_queue(queue):
    return queue.receive_messages(WaitTimeSeconds=20, MaxNumberOfMessages=10)


def _handle_message(received_message):
    logger.debug(received_message)
    message = json.loads(received_message.body)
    id = _convert_asset_id(message["asset"]["id"])
    success = True

    varnishUrl = f"{VARNISH_ADDRESS}/{id}"

    response = requests.request(
        "BAN",
        url=varnishUrl
    )

    if response.ok:
        logger.debug(f"banned {id}")
    else:
        success = False
        logger.error(f"failed to ban {id} - {response.status_code} {response.text}")

    return success


def _convert_asset_id(id):
    customer = id["customer"]
    space = id["space"]
    asset = id["asset"]

    return str(customer) + "/" + str(space) + "/" + str(asset)


if __name__ == "__main__":
    start_monitoring()
