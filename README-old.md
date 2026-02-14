
---

# **Complete Flask Project with Jenkins CI/CD**

### **Project Structure**

```
flask-app/
│
├── app.py                  # Flask application
├── requirements.txt        # Python dependencies
├── tests/
│   └── test_app.py         # Simple pytest tests
├── Dockerfile              # Docker container definition
├── Jenkinsfile             # CI/CD pipeline
└── README.md               # Project description
```

---

## **1. app.py**

```python
from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"message": "Hello, Flask!"})

@app.route('/add', methods=['POST'])
def add():
    data = request.get_json()
    result = data.get('a', 0) + data.get('b', 0)
    return jsonify({"result": result})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

## **2. requirements.txt**

```text
Flask==2.3.3
pytest==7.4.0
```

> Versions can be updated as needed.

---

## **3. tests/test_app.py**

```python
import pytest
from app import app

@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_home(client):
    response = client.get('/')
    assert response.status_code == 200
    assert response.get_json() == {"message": "Hello, Flask!"}

def test_add(client):
    response = client.post('/add', json={"a": 3, "b": 4})
    assert response.status_code == 200
    assert response.get_json() == {"result": 7}
```

---

## **4. Dockerfile**

```dockerfile
# Use official Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Expose port
EXPOSE 5000

# Start the Flask app
CMD ["python", "app.py"]
```

---

## **5. Jenkinsfile**

```groovy
pipeline {
    agent any

    environment {
        VENV = "venv"
        IMAGE_NAME = "mydockeruser/flask-app"
        TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup & Build') {
            steps {
                sh '''
                    python3 -m venv ${VENV}
                    . ${VENV}/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    . ${VENV}/bin/activate
                    pytest --junitxml=test-results.xml || true
                '''
                junit 'test-results.xml'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${TAG} .
                '''
            }
        }

        stage('Push Docker Image') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${IMAGE_NAME}:${TAG}
                        docker tag ${IMAGE_NAME}:${TAG} ${IMAGE_NAME}:latest
                        docker push ${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    echo "Deploying Flask app..."
                    # Example deploy: restart Docker container on server
                    # ssh user@server "docker pull ${IMAGE_NAME}:latest && docker stop flask-app && docker run -d --name flask-app -p 5000:5000 ${IMAGE_NAME}:latest"
                '''
            }
        }
    }
}
```

---

## **6. README.md**

````markdown
# Flask CI/CD Project

This is a sample Flask application with a Jenkins CI/CD pipeline.

## Features

- REST API with endpoints:
  - `GET /` → Hello message
  - `POST /add` → Adds two numbers
- Automated tests with pytest
- Docker containerization
- Jenkins CI/CD with stages:
  - Build
  - Test
  - Docker build
  - Docker push
  - Deploy

## Run Locally

```bash
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
python app.py
````

## Run Tests

```bash
pytest
```

## Docker

```bash
docker build -t flask-app .
docker run -p 5000:5000 flask-app
```

```

---

✅ This is a **fully working Flask project with Jenkins CI/CD**:

- `app.py` contains endpoints  
- `tests/` contains pytest tests  
- `requirements.txt` for dependencies  
- Dockerfile to containerize the app  
- Jenkinsfile for CI/CD pipeline  
- README.md explains everything  

---

If you want, I can **also create a FastAPI version** with the exact same structure, including async routes, Docker, and Jenkinsfile, ready for production.  

Do you want me to do that next?
```
