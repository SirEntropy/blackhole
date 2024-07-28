import tensorflow as tf
import jax
import jax.numpy as jnp
from flax import linen as nn
from flax.training import train_state
import optax

# Define the categories
categories = ["infrastructure", "deployment", "incident", "optimization", "testing"]


# Function to load your pre-trained TensorFlow model
def load_pretrained_model(model_path):
    return tf.saved_model.load(model_path)


# Define the classifier model
class DevOpsClassifier(nn.Module):
    embedding_size: int

    @nn.compact
    def __call__(self, inputs):
        x = nn.Dense(features=256)(inputs)
        x = nn.relu(x)
        x = nn.Dense(features=len(categories))(x)
        return x


# Create a function to get embeddings from your pre-trained model
def get_embeddings(pretrained_model, text):
    return pretrained_model(tf.constant([text]))["embeddings"]


# JIT-compile the forward pass
@jax.jit
def forward(model, params, inputs):
    return model.apply(params, inputs)


# Initialize parameters
def init_model(key, embedding_size):
    model = DevOpsClassifier(embedding_size=embedding_size)
    dummy_input = jnp.ones((1, embedding_size))
    return model, model.init(key, dummy_input)


# Create an optimizer
def create_optimizer(params):
    optimizer = optax.adam(learning_rate=1e-4)
    return optimizer, optimizer.init(params)


# Training function
def train_step(state, batch, labels):
    def loss_fn(params):
        logits = forward(params, batch)
        loss = optax.softmax_cross_entropy_with_integer_labels(logits, labels)
        return loss.mean()

    grad_fn = jax.value_and_grad(loss_fn)
    loss, grads = grad_fn(state.params)
    state = state.apply_gradients(grads=grads)
    return state, loss


# Prediction function
def predict(params, pretrained_model, text):
    embeddings = get_embeddings(pretrained_model, text)
    embeddings = jnp.array(embeddings)  # Convert TF tensor to JAX array
    logits = forward(params, embeddings)
    probabilities = jax.nn.softmax(logits)
    predicted_class = jnp.argmax(probabilities, axis=-1)
    return categories[predicted_class[0]]


# Main function to set up and use the classifier
def setup_classifier(pretrained_model_path, embedding_size):
    # Load your pre-trained model
    pretrained_model = load_pretrained_model(pretrained_model_path)

    # Initialize the classifier
    key = jax.random.PRNGKey(0)
    model, params = init_model(key, embedding_size)

    # Create optimizer
    optimizer, _ = create_optimizer(params)

    # Create training state
    state = train_state.TrainState.create(
        apply_fn=model.apply, params=params, tx=optimizer
    )

    return pretrained_model, state
