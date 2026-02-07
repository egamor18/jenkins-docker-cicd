
---

# **Step-by-Step Guide: Jenkins CI/CD for Flask / FastAPI**

## **Step 1: Project Structure**

Organize your project like this:

```
myapp/
│
├── app.py or main.py         # Flask or FastAPI entry point
├── requirements.txt          # Python dependencies
├── tests/                    # Automated test files
│   └── test_app.py
├── Dockerfile                # Container configuration
├── Jenkinsfile               # CI/CD pipeline definition
└── README.md
```

---

## **Step 2: Write a Dockerfile**

You only need **one Dockerfile**, which works for Flask or FastAPI by adjusting the CMD:

```dockerfile
# Use a lightweight Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project code
COPY . .

# Start the application
# For Flask, ensure your app.py is set
# For FastAPI, adjust to main.py with uvicorn
CMD ["python", "app.py"]          # Flask
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]  # FastAPI
```

> Tip: You can toggle CMD based on the framework you use.

---

## **Step 3: Write a Jenkinsfile**

This Jenkinsfile handles **build → test → Docker build → deploy**:

```groovy
pipeline {
    agent any

    environment {
        VENV = "venv"
        IMAGE_NAME = "mydockeruser/myapp"
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
                    echo "Deploying app..."
                    # Example: restart Docker container on remote server
                    # ssh user@server "docker pull ${IMAGE_NAME}:latest && docker stop myapp && docker run -d --name myapp ${IMAGE_NAME}:latest"
                '''
            }
        }
    }
}
```

---

## **Step 4: Key Points**

1. **Virtual Environment**

   * Keeps Python dependencies isolated:

     ```bash
     python3 -m venv venv
     . venv/bin/activate
     ```

2. **Testing**

   * Run tests with `pytest`
   * Save results for Jenkins UI: `--junitxml=test-results.xml`

3. **Docker Build & Push**

   * Build a Docker image for the app
   * Tag it with the build number for traceability
   * Push to Docker Hub only from the main branch

4. **Deploy**

   * Pull latest Docker image and restart container on server or orchestrator (Kubernetes, ECS, etc.)

---

## **Step 5: Adjusting for Flask vs FastAPI**

| Framework | Docker CMD                                                           | Notes                                              |
| --------- | -------------------------------------------------------------------- | -------------------------------------------------- |
| Flask     | `CMD ["python", "app.py"]`                                           | Ensure `app.py` contains `app.run(host="0.0.0.0")` |
| FastAPI   | `CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]` | Ensure `main.py` contains `app = FastAPI()`        |

> Only **one Dockerfile** is needed; just update the CMD depending on your framework.

---

## **Step 6: Best Practices**

* Archive test results with `junit` for historical reporting
* Use `archiveArtifacts` for Python build artifacts if needed
* Branch-based deploy ensures only main pushes trigger production
* Keep secrets (DockerHub credentials, API keys) in Jenkins credentials store

---

