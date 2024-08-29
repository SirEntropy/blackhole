from blackhole.dataprocessor.blueprints.devops_texts_blueprint import (
    devops_texts_blueprint,
)
from blackhole.dataprocessor.blueprints.incident_texts_blueprint import (
    incident_texts_blueprint,
)
from blackhole.dataprocessor.blueprints.infrastructure_texts_blueprint import (
    infrastructure_texts_blueprint,
)
from blackhole.dataprocessor.blueprints.codebase_texts_blueprint import (
    codebase_texts_blueprint,
)
from blackhole.dataprocessor.classification.classify import get_chat_response

from flask import Flask, request, jsonify
import os


app = Flask(__name__)

env = os.environ.get("FLASK_ENV", "development")
app.config.from_pyfile(f"config/{env}.py")

app.register_blueprint(infrastructure_texts_blueprint)
app.register_blueprint(devops_texts_blueprint)
app.register_blueprint(incident_texts_blueprint)
app.register_blueprint(codebase_texts_blueprint)


@app.route("/")
def index():
    return jsonify({"message": "Hello World"})


@app.route("/devops", methods=["POST"])
def classify():
    user_input = request.json.get("message")

    if not user_input:
        return jsonify({"error": "No input provided"}), 400

    try:
        response = get_chat_response(user_input)
        return jsonify({"response": response})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host=app.config["HOST"], port=app.config["PORT"], debug=app.config["DEBUG"])
