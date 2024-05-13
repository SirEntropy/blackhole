import boto3


class AwsClient:
    def __init__(self, resources: list):
        for resource in resources:
            if resource == "dynamodb":
                self._get_dynamodb_client()

    def _get_dynamodb_client(self):
        self.dynamodb_client = boto3.client("dynamodb")

    def store_data_to_dynamodb(self, table_name, data):
        self.dynamodb_client.put_item(TableName=table_name, Item=data)
