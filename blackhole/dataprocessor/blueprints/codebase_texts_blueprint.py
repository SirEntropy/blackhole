from flask import Blueprint
from flask_restx import Api, Resource, fields

codebase_texts_blueprint = Blueprint("codebase-texts", __name__)
api = Api(codebase_texts_blueprint)

model = api.model(
    "CodebaseTextsModel",
    {
        "text": fields.String(required=True, description="text"),
        "context": fields.String(required=False, description="context"),
        "answer": fields.String(required=False, description="answer"),
        "labels": fields.List(fields.String, required=False, description="labels"),
    },
)


@api.route("/codebase-texts")
class CodebaseTextsBlueprint(Resource):
    @api.doc(description="Get codebase texts data")
    def get(self):
        # Process the GET request data
        return {"message": "GET request received"}

    @api.expect(model)
    @api.doc(description="Store codebase texts data")
    def post(self):
        data = api.payload
        # Process the POST request data
        return {"message": "POST request received"}
