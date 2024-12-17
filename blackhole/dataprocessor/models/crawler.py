from flask_sqlalchemy import SQLAlchemy
from dataclasses import dataclass

# Initialize SQLAlchemy
db = SQLAlchemy()


# Define the CrawlerMetadata dataclass model
@dataclass
class CrawlerMetadata(db.Model):
    __tablename__ = "crawler_metadata"

    id: int = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name: str = db.Column(db.String(255), nullable=False)
    sampling_rate: float = db.Column(db.Float, nullable=False)
    frequency: int = db.Column(db.Integer, nullable=False)
    process_with_llm: bool = db.Column(db.Boolean, default=False)
