from flask import Blueprint
from flask_restx import Api, Resource, fields
from blackhole.common.clients.aws_client import AwsClient

devops_texts_blueprint = Blueprint("devops-texts", __name__)
api = Api(devops_texts_blueprint)

infra_dynamodb = AwsClient(resources=["dynamodb"])

model = api.model(
    "DevopsTextsModel",
    {
        "text": fields.String(required=True, description="text"),
        "context": fields.String(required=False, description="context"),
        "answer": fields.String(required=False, description="answer"),
        "labels": fields.List(fields.String, required=False, description="labels"),
    },
)


@api.route("/devops-texts")
class DevopsTextsBlueprint(Resource):
    @api.doc(description="Get devops texts data")
    def get(self):
        # Process the GET request data
        response = infra_dynamodb.get_all_data_from_dynamodb("devops_texts")
        return {"message": response}

    @api.expect(model)
    @api.doc(description="Store devops texts data")
    def post(self):
        data = api.payload
        # Process the POST request data
        return {"message": "POST request received"}
