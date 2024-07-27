import jax.numpy as jnp
import optax
from jax import grad, jit, random
import tensorflow as tf

# Sample cleaned texts and labels
texts = ["text data example one", "another text example", "more text data here"]
labels = [0, 1, 0]

# TensorFlow text vectorization
vectorizer = tf.keras.layers.TextVectorization(output_mode="tf-idf")
vectorizer.adapt(texts)
X = vectorizer(texts).numpy()
y = jnp.array(labels)

# Split data into train and test sets (manually since not using sklearn)
split_index = int(len(X) * 0.8)
X_train, X_test = X[:split_index], X[split_index:]
y_train, y_test = y[:split_index], y[split_index:]


# Define model: Simple logistic regression
def sigmoid(x):
    return 1 / (1 + jnp.exp(-x))


def predict(params, x):
    return sigmoid(jnp.dot(x, params))


def loss(params, x, y):
    preds = predict(params, x)
    return -jnp.mean(y * jnp.log(preds) + (1 - y) * jnp.log(1 - preds))


# Initialize parameters
key = random.PRNGKey(0)
params = random.normal(key, (X_train.shape[1],))

# Define optimizer
learning_rate = 0.1
optimizer = optax.sgd(learning_rate)

# Initialize optimizer state
opt_state = optimizer.init(params)


# Training step
@jit
def train_step(params, opt_state, x, y):
    grads = grad(loss)(params, x, y)
    updates, opt_state = optimizer.update(grads, opt_state)
    params = optax.apply_updates(params, updates)
    return params, opt_state


# Training loop
num_epochs = 100
for epoch in range(num_epochs):
    params, opt_state = train_step(params, opt_state, X_train, y_train)
    if epoch % 10 == 0:
        train_loss = loss(params, X_train, y_train)
        test_loss = loss(params, X_test, y_test)
        print(f"Epoch {epoch}, Train Loss: {train_loss}, Test Loss: {test_loss}")

# Predict on test data
preds = predict(params, X_test)
pred_labels = preds > 0.5

print("Predictions:", pred_labels)
print("Actual labels:", y_test)
