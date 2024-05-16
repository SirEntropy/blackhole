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

from flask import Flask, request, jsonify
import yaml
import logging
import os


app = Flask(__name__)

env = os.environ.get("FLASK_ENV", "development")
app.config.from_pyfile(f"config/{env}.py")

app.register_blueprint(devops_texts_blueprint)
app.register_blueprint(incident_texts_blueprint)
app.register_blueprint(infrastructure_texts_blueprint)
app.register_blueprint(codebase_texts_blueprint)


@app.route("/")
def index():
    return jsonify({"message": "Hello World"})


if __name__ == "__main__":
    app.run(host=app.config["HOST"], port=app.config["PORT"], debug=app.config["DEBUG"])
