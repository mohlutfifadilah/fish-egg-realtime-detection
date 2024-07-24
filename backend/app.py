from flask import Flask, request, jsonify
import onnxruntime as ort
from PIL import Image
import numpy as np
import os

app = Flask(__name__)

# Load ONNX model
model_path = 'model.onnx'
session = ort.InferenceSession(model_path)

def preprocess(image_path):
    image = Image.open(image_path)
    image = image.resize((224, 224))
    image_data = np.array(image).astype('float32')
    image_data = np.expand_dims(image_data, axis=0)
    return image_data

def postprocess(output):
    # Implement your postprocessing logic here
    detections = []
    # Example postprocess code
    for i in range(len(output[0])):
        detection = {
            'x': float(output[0][i][0]),
            'y': float(output[0][i][1]),
            'width': float(output[0][i][2]),
            'height': float(output[0][i][3]),
        }
        detections.append(detection)
    return detections

@app.route('/run_model', methods=['POST'])
def run_model():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part in the request'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected for uploading'}), 400
    
    if file:
        file_path = os.path.join('uploads', file.filename)
        file.save(file_path)
        
        # Preprocess the image
        input_data = preprocess(file_path)
        
        # Run the model
        output = session.run(None, {'input': input_data})
        
        # Postprocess the output
        detections = postprocess(output)
        
        return jsonify({'detections': detections})

if __name__ == '__main__':
    if not os.path.exists('uploads'):
        os.makedirs('uploads')
    app.run(host='0.0.0.0', port=5000)
