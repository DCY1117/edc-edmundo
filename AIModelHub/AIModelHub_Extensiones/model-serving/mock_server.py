"""
Mock AI Model Server
====================

Servidor mock que simula modelos de IA ejecutables.
Expone endpoints HTTP para pruebas de la funcionalidad de ejecución.

Features:
- Múltiples modelos simulados (Iris, Sentiment, Image Classification)
- UI web interactiva para monitorear requests
- Respuestas realistas con latencia simulada
- Logs de ejecuciones

Puerto: 8080
"""

from flask import Flask, request, jsonify, render_template_string
from flask_cors import CORS
from datetime import datetime
import time
import random
import json

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# In-memory execution log
execution_log = []

# ============================================================================
# MODEL DEFINITIONS
# ============================================================================

def iris_classifier(data):
    """Simula clasificación de flores Iris"""
    time.sleep(random.uniform(0.5, 1.5))  # Simular procesamiento
    
    # Extraer features
    sepal_length = data.get('sepal_length', 5.0)
    sepal_width = data.get('sepal_width', 3.0)
    petal_length = data.get('petal_length', 4.0)
    petal_width = data.get('petal_width', 1.5)
    
    # Lógica simple de clasificación
    if petal_length < 2.5:
        species = 'setosa'
        confidence = 0.95
    elif petal_length < 5.0:
        species = 'versicolor'
        confidence = 0.87
    else:
        species = 'virginica'
        confidence = 0.92
    
    return {
        'model': 'Iris Classifier',
        'prediction': species,
        'confidence': confidence,
        'probabilities': {
            'setosa': 0.95 if species == 'setosa' else random.uniform(0.01, 0.05),
            'versicolor': 0.87 if species == 'versicolor' else random.uniform(0.05, 0.15),
            'virginica': 0.92 if species == 'virginica' else random.uniform(0.01, 0.08)
        },
        'input_features': {
            'sepal_length': sepal_length,
            'sepal_width': sepal_width,
            'petal_length': petal_length,
            'petal_width': petal_width
        }
    }

def sentiment_analyzer(data):
    """Simula análisis de sentimiento"""
    time.sleep(random.uniform(0.3, 1.0))
    
    text = data.get('text', '')
    
    # Análisis simple basado en palabras clave
    positive_words = ['good', 'great', 'excellent', 'love', 'amazing', 'wonderful', 'happy']
    negative_words = ['bad', 'terrible', 'hate', 'awful', 'horrible', 'sad', 'angry']
    
    text_lower = text.lower()
    pos_count = sum(word in text_lower for word in positive_words)
    neg_count = sum(word in text_lower for word in negative_words)
    
    if pos_count > neg_count:
        sentiment = 'positive'
        score = 0.7 + random.uniform(0, 0.25)
    elif neg_count > pos_count:
        sentiment = 'negative'
        score = 0.7 + random.uniform(0, 0.25)
    else:
        sentiment = 'neutral'
        score = 0.5 + random.uniform(-0.1, 0.1)
    
    return {
        'model': 'Sentiment Analyzer',
        'sentiment': sentiment,
        'score': round(score, 3),
        'confidence': round(score, 3),
        'text_analyzed': text[:100] + ('...' if len(text) > 100 else ''),
        'keywords_detected': {
            'positive': pos_count,
            'negative': neg_count
        }
    }

def image_classifier(data):
    """Simula clasificación de imágenes médicas (Chest X-Ray)"""
    time.sleep(random.uniform(1.0, 2.0))  # Más lento, simula procesamiento pesado
    
    # Datos de entrada esperados
    image_data = data.get('image_base64', '')
    patient_age = data.get('patient_age', 45)
    
    # Clasificación de X-Ray
    conditions = ['Normal', 'Pneumonia', 'COVID-19', 'Tuberculosis', 'Lung Cancer']
    predicted_condition = random.choice(conditions)
    
    # Confidence más alta para Normal, más baja para otras
    if predicted_condition == 'Normal':
        confidence = random.uniform(0.85, 0.98)
    else:
        confidence = random.uniform(0.70, 0.90)
    
    # Generar probabilidades para todas las clases
    probabilities = {}
    remaining = 1.0 - confidence
    for condition in conditions:
        if condition == predicted_condition:
            probabilities[condition] = confidence
        else:
            prob = random.uniform(0, remaining / (len(conditions) - 1))
            probabilities[condition] = round(prob, 4)
    
    return {
        'model': 'Chest X-Ray Classifier',
        'prediction': predicted_condition,
        'confidence': round(confidence, 3),
        'probabilities': probabilities,
        'patient_age': patient_age,
        'risk_level': 'high' if confidence > 0.85 and predicted_condition != 'Normal' else 'low',
        'processing_time_ms': round(random.uniform(1000, 2000), 2)
    }

def fraud_detector(data):
    """Simula detección de fraude en transacciones"""
    time.sleep(random.uniform(0.5, 1.2))
    
    # Datos de entrada esperados
    amount = data.get('transaction_amount', 100.0)
    merchant = data.get('merchant_category', 'retail')
    location = data.get('location', 'domestic')
    hour = data.get('transaction_hour', 12)
    card_present = data.get('card_present', True)
    
    # Lógica de detección
    fraud_score = 0.0
    
    # Factores de riesgo
    if amount > 1000:
        fraud_score += 0.3
    if location == 'international':
        fraud_score += 0.2
    if hour < 6 or hour > 22:
        fraud_score += 0.15
    if not card_present:
        fraud_score += 0.25
    if merchant in ['electronics', 'jewelry', 'cash_advance']:
        fraud_score += 0.1
    
    # Añadir ruido aleatorio
    fraud_score += random.uniform(-0.1, 0.1)
    fraud_score = max(0.0, min(1.0, fraud_score))
    
    is_fraud = fraud_score > 0.5
    
    return {
        'model': 'Fraud Detector',
        'is_fraud': is_fraud,
        'fraud_probability': round(fraud_score, 3),
        'risk_level': 'high' if fraud_score > 0.7 else 'medium' if fraud_score > 0.4 else 'low',
        'risk_factors': {
            'high_amount': amount > 1000,
            'unusual_location': location == 'international',
            'unusual_time': hour < 6 or hour > 22,
            'card_not_present': not card_present,
            'risky_merchant': merchant in ['electronics', 'jewelry', 'cash_advance']
        },
        'transaction_details': {
            'amount': amount,
            'merchant': merchant,
            'location': location,
            'hour': hour
        }
    }

def speech_recognizer(data):
    """Simula reconocimiento automático de voz (ASR)"""
    time.sleep(random.uniform(1.5, 3.0))  # Simula procesamiento de audio
    
    # Datos de entrada esperados
    audio_duration = data.get('audio_duration_seconds', 5.0)
    language = data.get('language', 'en')
    audio_quality = data.get('audio_quality', 'good')
    
    # Textos de ejemplo por idioma
    sample_texts = {
        'en': [
            "Hello, how can I help you today?",
            "The weather is nice today.",
            "I would like to schedule an appointment.",
            "Thank you for calling our customer service."
        ],
        'es': [
            "Hola, ¿cómo puedo ayudarte hoy?",
            "El clima está agradable hoy.",
            "Me gustaría programar una cita.",
            "Gracias por llamar a nuestro servicio al cliente."
        ],
        'fr': [
            "Bonjour, comment puis-je vous aider aujourd'hui?",
            "Le temps est agréable aujourd'hui.",
            "Je voudrais prendre rendez-vous.",
            "Merci d'avoir appelé notre service client."
        ]
    }
    
    transcription = random.choice(sample_texts.get(language, sample_texts['en']))
    
    # Confidence basada en calidad de audio
    if audio_quality == 'excellent':
        confidence = random.uniform(0.92, 0.99)
    elif audio_quality == 'good':
        confidence = random.uniform(0.80, 0.92)
    else:
        confidence = random.uniform(0.60, 0.80)
    
    word_count = len(transcription.split())
    
    return {
        'model': 'Multilingual ASR',
        'transcription': transcription,
        'confidence': round(confidence, 3),
        'language_detected': language,
        'audio_duration': audio_duration,
        'word_count': word_count,
        'words_per_second': round(word_count / audio_duration, 2) if audio_duration > 0 else 0,
        'audio_quality': audio_quality,
        'processing_time_ms': round(random.uniform(1500, 3000), 2)
    }

# ============================================================================
# API ENDPOINTS
# ============================================================================

@app.route('/')
def home():
    """Dashboard HTML"""
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>🤖 AI Model Server - Mock Dashboard</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: #333;
                min-height: 100vh;
                padding: 20px;
            }
            .container {
                max-width: 1200px;
                margin: 0 auto;
            }
            .header {
                background: white;
                padding: 30px;
                border-radius: 15px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
                margin-bottom: 30px;
                text-align: center;
            }
            .header h1 {
                color: #667eea;
                font-size: 2.5rem;
                margin-bottom: 10px;
            }
            .header .status {
                display: inline-block;
                background: #10b981;
                color: white;
                padding: 8px 20px;
                border-radius: 20px;
                font-weight: 600;
                margin-top: 10px;
            }
            .header .status::before {
                content: '●';
                margin-right: 8px;
                animation: pulse 2s infinite;
            }
            @keyframes pulse {
                0%, 100% { opacity: 1; }
                50% { opacity: 0.5; }
            }
            .stats {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
                margin-bottom: 30px;
            }
            .stat-card {
                background: white;
                padding: 25px;
                border-radius: 15px;
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
                text-align: center;
            }
            .stat-card .number {
                font-size: 2.5rem;
                font-weight: bold;
                color: #667eea;
                margin: 10px 0;
            }
            .stat-card .label {
                color: #666;
                font-size: 0.9rem;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            .models-section {
                background: white;
                padding: 30px;
                border-radius: 15px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
                margin-bottom: 30px;
            }
            .models-section h2 {
                color: #667eea;
                margin-bottom: 20px;
                font-size: 1.8rem;
            }
            .model-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                gap: 20px;
            }
            .model-card {
                border: 2px solid #e5e7eb;
                padding: 20px;
                border-radius: 10px;
                transition: all 0.3s;
            }
            .model-card:hover {
                border-color: #667eea;
                box-shadow: 0 5px 15px rgba(102, 126, 234, 0.2);
                transform: translateY(-2px);
            }
            .model-card h3 {
                color: #333;
                margin-bottom: 10px;
            }
            .model-card .endpoint {
                background: #f3f4f6;
                padding: 8px 12px;
                border-radius: 5px;
                font-family: 'Courier New', monospace;
                font-size: 0.85rem;
                color: #667eea;
                margin: 10px 0;
                word-break: break-all;
            }
            .model-card .method {
                display: inline-block;
                background: #10b981;
                color: white;
                padding: 4px 10px;
                border-radius: 5px;
                font-size: 0.8rem;
                font-weight: 600;
                margin-right: 10px;
            }
            .log-section {
                background: white;
                padding: 30px;
                border-radius: 15px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            }
            .log-section h2 {
                color: #667eea;
                margin-bottom: 20px;
                font-size: 1.8rem;
            }
            .log-entry {
                border-left: 4px solid #667eea;
                background: #f9fafb;
                padding: 15px;
                margin-bottom: 15px;
                border-radius: 5px;
                font-size: 0.9rem;
            }
            .log-entry .timestamp {
                color: #666;
                font-size: 0.85rem;
                margin-bottom: 5px;
            }
            .log-entry .status-success {
                color: #10b981;
                font-weight: 600;
            }
            .log-entry .status-error {
                color: #ef4444;
                font-weight: 600;
            }
            .refresh-btn {
                background: #667eea;
                color: white;
                border: none;
                padding: 12px 30px;
                border-radius: 8px;
                font-size: 1rem;
                font-weight: 600;
                cursor: pointer;
                margin-top: 20px;
                transition: background 0.3s;
            }
            .refresh-btn:hover {
                background: #5568d3;
            }
            .empty-log {
                text-align: center;
                color: #999;
                padding: 40px;
                font-style: italic;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🤖 AI Model Server</h1>
                <p style="color: #666; margin: 10px 0;">Mock Server for Model Execution Testing</p>
                <div class="status">ONLINE</div>
            </div>
            
            <div class="stats">
                <div class="stat-card">
                    <div class="label">Total Requests</div>
                    <div class="number" id="totalRequests">{{ total_requests }}</div>
                </div>
                <div class="stat-card">
                    <div class="label">Available Models</div>
                    <div class="number">3</div>
                </div>
                <div class="stat-card">
                    <div class="label">Server Port</div>
                    <div class="number">8080</div>
                </div>
            </div>
            
            <div class="models-section">
                <h2>📊 Available Models</h2>
                <div class="model-grid">
                    <div class="model-card">
                        <h3>🌸 Iris Classifier</h3>
                        <p style="color: #666; margin: 10px 0;">Classifies iris flowers into species based on measurements</p>
                        <div class="endpoint">POST /api/v1/predict</div>
                        <div style="margin-top: 10px;">
                            <span class="method">POST</span>
                            <small style="color: #666;">Requires: sepal_length, sepal_width, petal_length, petal_width</small>
                        </div>
                    </div>
                    
                    <div class="model-card">
                        <h3>💭 Sentiment Analyzer</h3>
                        <p style="color: #666; margin: 10px 0;">Analyzes text sentiment (positive, negative, neutral)</p>
                        <div class="endpoint">POST /api/v1/sentiment</div>
                        <div style="margin-top: 10px;">
                            <span class="method">POST</span>
                            <small style="color: #666;">Requires: text</small>
                        </div>
                    </div>
                    
                    <div class="model-card">
                        <h3>🖼️ Image Classifier</h3>
                        <p style="color: #666; margin: 10px 0;">Classifies images into categories</p>
                        <div class="endpoint">POST /api/v1/classify-image</div>
                        <div style="margin-top: 10px;">
                            <span class="method">POST</span>
                            <small style="color: #666;">Requires: image_data or image_url</small>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="log-section">
                <h2>📝 Recent Executions</h2>
                <div id="logContainer">
                    {% if execution_log %}
                        {% for log in execution_log[-10:][::-1] %}
                        <div class="log-entry">
                            <div class="timestamp">{{ log.timestamp }}</div>
                            <div>
                                <span class="status-{{ log.status }}">{{ log.status.upper() }}</span>
                                <strong>{{ log.model }}</strong> - {{ log.endpoint }}
                            </div>
                            <div style="margin-top: 5px; color: #666;">
                                Duration: {{ log.duration }}ms
                            </div>
                        </div>
                        {% endfor %}
                    {% else %}
                        <div class="empty-log">
                            No executions yet. Try calling one of the model endpoints!
                        </div>
                    {% endif %}
                </div>
                <button class="refresh-btn" onclick="location.reload()">🔄 Refresh</button>
            </div>
        </div>
        
        <script>
            // Auto-refresh every 5 seconds
            setTimeout(() => location.reload(), 5000);
        </script>
    </body>
    </html>
    """
    return render_template_string(html, 
                                  execution_log=execution_log,
                                  total_requests=len(execution_log))

@app.route('/api/v1/predict', methods=['POST'])
def predict_iris():
    """Iris Classification Endpoint"""
    start_time = time.time()
    
    try:
        data = request.get_json()
        result = iris_classifier(data)
        
        # Log execution
        execution_log.append({
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'model': 'Iris Classifier',
            'endpoint': '/api/v1/predict',
            'status': 'success',
            'duration': round((time.time() - start_time) * 1000, 2)
        })
        
        return jsonify(result), 200
    
    except Exception as e:
        execution_log.append({
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'model': 'Iris Classifier',
            'endpoint': '/api/v1/predict',
            'status': 'error',
            'duration': round((time.time() - start_time) * 1000, 2)
        })
        return jsonify({'error': str(e)}), 500

@app.route('/api/v1/sentiment', methods=['POST'])
def analyze_sentiment():
    """Sentiment Analysis Endpoint"""
    start_time = time.time()
    
    try:
        data = request.get_json()
        result = sentiment_analyzer(data)
        
        execution_log.append({
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'model': 'Sentiment Analyzer',
            'endpoint': '/api/v1/sentiment',
            'status': 'success',
            'duration': round((time.time() - start_time) * 1000, 2)
        })
        
        return jsonify(result), 200
    
    except Exception as e:
        execution_log.append({
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'model': 'Sentiment Analyzer',
            'endpoint': '/api/v1/sentiment',
            'status': 'error',
            'duration': round((time.time() - start_time) * 1000, 2)
        })
        return jsonify({'error': str(e)}), 500

@app.route('/api/v1/classify-image', methods=['POST'])
def classify_image():
    """Image Classification Endpoint (Chest X-Ray)"""
    start_time = time.time()
    
    try:
        data = request.get_json()
        result = image_classifier(data)
        
        execution_log.append({
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'model': 'Chest X-Ray Classifier',
            'endpoint': '/api/v1/classify-image',
            'status': 'success',
            'duration': round((time.time() - start_time) * 1000, 2)
        })
        
        return jsonify(result), 200
    
    except Exception as e:
        execution_log.append({
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'model': 'Chest X-Ray Classifier',
            'endpoint': '/api/v1/classify-image',
            'status': 'error',
            'duration': round((time.time() - start_time) * 1000, 2)
        })
        return jsonify({'error': str(e)}), 500

@app.route('/api/v1/detect-fraud', methods=['POST'])
def detect_fraud():
    """Fraud Detection Endpoint
    
    Expected JSON input:
    {
        "transaction_amount": 150.00,
        "merchant_category": "retail",
        "location": "domestic",
        "transaction_hour": 14,
        "card_present": true
    }
    """
    start_time = time.time()
    
    try:
        data = request.get_json()
        result = fraud_detector(data)
        
        execution_log.append({
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'model': 'Fraud Detector',
            'endpoint': '/api/v1/detect-fraud',
            'status': 'success',
            'duration': round((time.time() - start_time) * 1000, 2)
        })
        
        return jsonify(result), 200
    
    except Exception as e:
        execution_log.append({
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'model': 'Fraud Detector',
            'endpoint': '/api/v1/detect-fraud',
            'status': 'error',
            'duration': round((time.time() - start_time) * 1000, 2)
        })
        return jsonify({'error': str(e)}), 500

@app.route('/api/v1/transcribe-audio', methods=['POST'])
def transcribe_audio():
    """Speech Recognition Endpoint (Multilingual ASR)
    
    Expected JSON input:
    {
        "audio_duration_seconds": 5.0,
        "language": "en",
        "audio_quality": "good"
    }
    
    Supported languages: en, es, fr
    Audio quality: excellent, good, poor
    """
    start_time = time.time()
    
    try:
        data = request.get_json()
        result = speech_recognizer(data)
        
        execution_log.append({
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'model': 'Multilingual ASR',
            'endpoint': '/api/v1/transcribe-audio',
            'status': 'success',
            'duration': round((time.time() - start_time) * 1000, 2)
        })
        
        return jsonify(result), 200
    
    except Exception as e:
        execution_log.append({
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'model': 'Multilingual ASR',
            'endpoint': '/api/v1/transcribe-audio',
            'status': 'error',
            'duration': round((time.time() - start_time) * 1000, 2)
        })
        return jsonify({'error': str(e)}), 500

@app.route('/api/v1/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'models': ['iris-classifier', 'sentiment-analyzer', 'image-classifier'],
        'total_requests': len(execution_log),
        'timestamp': datetime.now().isoformat()
    }), 200

if __name__ == '__main__':
    print("=" * 70)
    print("🤖 AI Model Mock Server Starting...")
    print("=" * 70)
    print(f"📊 Dashboard: http://localhost:8080")
    print(f"🔌 API Endpoints:")
    print(f"   - POST http://localhost:8080/api/v1/predict (Iris Classifier)")
    print(f"   - POST http://localhost:8080/api/v1/sentiment (Sentiment Analyzer)")
    print(f"   - POST http://localhost:8080/api/v1/classify-image (Image Classifier)")
    print(f"   - GET  http://localhost:8080/api/v1/health (Health Check)")
    print("=" * 70)
    print("✨ Server ready for model execution testing!")
    print("=" * 70)
    
    app.run(host='0.0.0.0', port=8080, debug=False)
