import jax.numpy as jnp
from tqdm import tqdm
import json
from datetime import datetime

from blackhole.trainer.devops_classifier import categories, get_embeddings, forward


def calculate_metrics(y_true, y_pred, num_classes):
    y_true = jnp.array(y_true)
    y_pred = jnp.array(y_pred)

    # Overall accuracy
    accuracy = jnp.mean(y_true == y_pred)

    # Per-class metrics
    metrics = []
    for c in range(num_classes):
        true_positives = jnp.sum((y_true == c) & (y_pred == c))
        false_positives = jnp.sum((y_true != c) & (y_pred == c))
        false_negatives = jnp.sum((y_true == c) & (y_pred != c))

        precision = true_positives / (true_positives + false_positives + 1e-8)
        recall = true_positives / (true_positives + false_negatives + 1e-8)
        f1_score = 2 * (precision * recall) / (precision + recall + 1e-8)

        metrics.append(
            {
                "precision": float(precision),
                "recall": float(recall),
                "f1_score": float(f1_score),
            }
        )

    return float(accuracy), metrics


def validate_classifier(model, state, pretrained_model, validation_data, batch_size=32):
    all_predictions = []
    all_true_labels = []

    # Process validation data in batches
    for i in tqdm(range(0, len(validation_data), batch_size)):
        batch = validation_data[i : i + batch_size]
        texts, true_labels = zip(*batch)

        # Get embeddings for the batch
        embeddings = jnp.array(
            [get_embeddings(pretrained_model, text) for text in texts]
        )

        # Get predictions
        logits = forward(model, state.params, embeddings)
        predictions = jnp.argmax(logits, axis=-1)

        all_predictions.extend(predictions)
        all_true_labels.extend(true_labels)

    # Calculate metrics
    accuracy, per_class_metrics = calculate_metrics(
        all_true_labels, all_predictions, len(categories)
    )

    # Create a results dictionary
    results = {"overall_accuracy": accuracy, "per_category_metrics": {}}

    for i, category in enumerate(categories):
        results["per_category_metrics"][category] = per_class_metrics[i]

    return results


def export_validation_results(results, file_path=None):
    if file_path is None:
        # Generate a default file name with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        file_path = f"validation_results_{timestamp}.json"

    # Add some metadata to the results
    results["metadata"] = {
        "timestamp": datetime.now().isoformat(),
        "num_categories": len(categories),
        "categories": categories,
    }

    # Write the results to a JSON file
    with open(file_path, "w") as f:
        json.dump(results, f, indent=2)

    return file_path
