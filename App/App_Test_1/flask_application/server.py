from fastapi import FastAPI, File, UploadFile
import shutil
from PIL import Image
import numpy as np
import tensorflow as tf
import uvicorn

app = FastAPI()

# Load your TensorFlow model
model = tf.keras.models.load_model("best_model.h5")

# Define label mappings
LABELS = {0: "Capacitor", 1: "Resistor", 2: "Transistor"}


# Function to preprocess image
def preprocess_image(image_path):
    image = Image.open(image_path).convert("RGB")
    image = image.resize((224, 224))  # Adjust size based on your model input
    image_array = np.array(image) / 255.0  # Normalize pixels
    image_array = np.expand_dims(image_array, axis=0)  # Add batch dimension
    return image_array


# Function to make a prediction
def predict_image(image_path):
    processed_image = preprocess_image(image_path)

    # Get prediction probabilities for all classes
    predictions = model.predict(processed_image)[0]  # Get the first (only) result
    predicted_class = np.argmax(predictions)  # Get class index
    confidence = predictions[predicted_class]  # Get confidence score
    predicted_label = LABELS.get(predicted_class, "Unknown")

    # Extract confidence for all other classes
    other_confidences = {
        LABELS[i]: float(predictions[i])
        for i in range(len(predictions))
        if i != predicted_class
    }

    return predicted_label, confidence, other_confidences


# API Endpoint to Receive Image and Predict
@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    file_location = "temp_image.jpg"

    # Save uploaded image
    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Get prediction & other confidences
    prediction, confidence, other_confidences = predict_image(file_location)

    return {
        "prediction": prediction,
        "confidence": float(confidence),
        "other_confidences": other_confidences,
    }


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
