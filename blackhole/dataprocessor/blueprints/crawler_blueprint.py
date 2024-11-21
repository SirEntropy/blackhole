from flask import Blueprint, request, jsonify
from blackhole.dataprocessor.models.crawler import CrawlerMetadata, db

# Define the blueprint
crawler_bp = Blueprint("crawler", __name__)


# Define POST route to add new metadata
@crawler_bp.route("/crawler", methods=["POST"])
def add_crawler_metadata():
    try:
        # Get JSON data from the request
        data = request.json

        # Validate and parse fields
        name = data.get("name")
        sampling_rate = data.get("sampling_rate")
        frequency = data.get("frequency")
        process_with_llm = data.get("process_with_llm", False)

        # Ensure required fields are provided
        if not name or sampling_rate is None or frequency is None:
            return (
                jsonify(
                    {
                        "error": "Missing required fields: 'name', 'sampling_rate', 'frequency'"
                    }
                ),
                400,
            )

        # Create a new CrawlerMetadata instance
        new_metadata = CrawlerMetadata(
            name=name,
            sampling_rate=sampling_rate,
            frequency=frequency,
            process_with_llm=process_with_llm,
        )

        # Add to database
        db.session.add(new_metadata)
        db.session.commit()

        # Return success response
        return (
            jsonify(
                {
                    "message": "Crawler metadata added successfully!",
                    "id": new_metadata.id,
                }
            ),
            201,
        )
    except Exception as e:
        return jsonify({"error": str(e)}), 500
