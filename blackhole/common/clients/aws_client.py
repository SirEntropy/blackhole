import boto3


class AwsClient:
    def __init__(self, resources: list):
        for resource in resources:
            if resource == "dynamodb":
                self._get_dynamodb_client()

    def _get_dynamodb_client(self):
        self.dynamodb_client = boto3.resource("dynamodb")

    def store_data_to_dynamodb(self, table_name, data):
        self.dynamodb_client.put_item(TableName=table_name, Item=data)

    def get_data_from_dynamodb(self, table_name, key):
        if not self.dynamodb_client:
            self._get_dynamodb_client()

        table = self.dynamodb_client.Table(table_name)
        response = table.get_item(Key={"primary_key_name": key})
        return response["Item"]

    def get_all_data_from_dynamodb(self, table_name):
        if not self.dynamodb_client:
            self._get_dynamodb_client()

        table = self.dynamodb_client.Table(table_name)
        response = table.scan()
        return response["Items"]
