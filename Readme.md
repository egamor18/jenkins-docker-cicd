
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
See 'Dockerfile'

> Tip: You can toggle CMD based on the framework you use.

---

## **Step 3: Write a Jenkinsfile**

This Jenkinsfile handles **build → test → Docker build → deploy**:

* See Jenkinsfile

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

## **Step 5: Best Practices**

* Archive test results with `junit` for historical reporting
* Use `archiveArtifacts` for Python build artifacts if needed
* Branch-based deploy ensures only main pushes trigger production
* Keep secrets (DockerHub credentials, API keys) in Jenkins credentials store

---

