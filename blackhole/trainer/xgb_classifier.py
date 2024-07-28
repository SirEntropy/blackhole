import tensorflow as tf
import tensorflow_decision_forests as tfdf
import pandas as pd
import numpy as np


def load_data():
    # todo: Load data from a CSV file
    # Return a pandas DataFrame with 'text' and 'label' columns
    pass


def split_data(df, test_size=0.2):
    np.random.seed(42)
    mask = np.random.rand(len(df)) < (1 - test_size)
    return df[mask], df[~mask]


def create_vectorizer(texts, max_features=1000, sequence_length=50):
    vectorizer = tf.keras.layers.TextVectorization(
        max_tokens=max_features,
        output_mode="tf-idf",
        output_sequence_length=sequence_length,
    )
    vectorizer.adapt(texts)
    return vectorizer


def create_label_index(labels):
    return {label: index for index, label in enumerate(labels.unique())}


def encode_labels(labels, label_to_index):
    return [label_to_index[label] for label in labels]


def create_dataset(texts, labels, vectorizer, shuffle=True, batch_size=32):
    texts = vectorizer(texts)
    ds = tf.data.Dataset.from_tensor_slices((texts, labels))
    if shuffle:
        ds = ds.shuffle(buffer_size=len(texts))
    ds = ds.batch(batch_size)
    return ds


def create_model(num_trees=100, max_depth=6):
    return tfdf.keras.GradientBoostedTreesModel(
        num_trees=num_trees,
        max_depth=max_depth,
        task=tfdf.keras.Task.CLASSIFICATION,
        verbose=1,
    )


def train_model(model, train_dataset):
    model.compile(metrics=["accuracy"])
    model.fit(train_dataset)
    return model


def evaluate_model(model, test_dataset):
    evaluation = model.evaluate(test_dataset)
    return evaluation[1]  # Return accuracy


def create_prediction_function(model, vectorizer, label_to_index):
    class_names = list(label_to_index.keys())

    def predict(text):
        features = vectorizer([text])
        predictions = model.predict(features)
        predicted_class = tf.argmax(predictions, axis=1).numpy()[0]
        return class_names[predicted_class]

    return predict


def setup_classifier():
    df = load_data()
    train_df, test_df = split_data(df)

    vectorizer = create_vectorizer(train_df["text"])
    label_to_index = create_label_index(df["label"])

    train_labels = encode_labels(train_df["label"], label_to_index)
    test_labels = encode_labels(test_df["label"], label_to_index)

    train_dataset = create_dataset(train_df["text"].values, train_labels, vectorizer)
    test_dataset = create_dataset(
        test_df["text"].values, test_labels, vectorizer, shuffle=False
    )

    model = create_model()
    trained_model = train_model(model, train_dataset)

    accuracy = evaluate_model(trained_model, test_dataset)
    print(f"Test accuracy: {accuracy:.4f}")

    predict_function = create_prediction_function(
        trained_model, vectorizer, label_to_index
    )

    return trained_model, predict_function, vectorizer
