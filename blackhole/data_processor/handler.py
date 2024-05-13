"""
Handlers for processing api data.
"""

from blackhole.common.clients.aws_client import AwsClient
from blackhole.common.error_handler import error_handler


# pylint: disable=missing-function-docstring
@error_handler
def store_devops_texts(data: dict):
    aws_client = AwsClient(["dynamodb"])
    aws_client.store_data_to_dynamodb("data_table", data)
