from flask import Blueprint
from flask_restx import Api, Resource, fields

infrastructure_texts_blueprint = Blueprint("infrastructure-texts", __name__)
api = Api(infrastructure_texts_blueprint)

model = api.model(
    "InfrastructureTextsModel",
    {
        "text": fields.String(required=True, description="text"),
        "context": fields.String(required=False, description="context"),
        "answer": fields.String(required=False, description="answer"),
        "labels": fields.List(fields.String, required=False, description="labels"),
    },
)


@api.route("/infrastructure-texts")
class InfrastructureTextsBlueprint(Resource):
    @api.doc(description="Get infrastructure texts data")
    def get(self):
        # Process the GET request data
        return {"message": "GET request received"}

    @api.expect(model)
    @api.doc(description="Store infrastructure texts data")
    def post(self):
        data = api.payload
        # Process the POST request data
        return {"message": "POST request received"}
