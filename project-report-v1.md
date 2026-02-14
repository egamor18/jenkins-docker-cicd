

---
### PROJECT: AUTOMATIC BUILDING, TESTING, AND DEPLOYMENT OF MICROSERVICE-BASED APPLICATION USING JENKINS (CI / CD)
---

# What is Jenkins? — Use Case Explanation

Jenkins is an **automation server** used to implement **Continuous Integration (CI)** and **Continuous Delivery / Deployment (CD)**.

In practical terms, Jenkins automates the process of:

* Building applications
* Running tests
* Packaging artifacts (e.g. Docker images)
* Deploying applications to target environments

In this project, Jenkins acts as the **central orchestrator** that reacts to code changes and executes a predefined pipeline to build, test, package, and deploy a **microservice-based application**.

---

# High-Level Flow Summary

```
Developer → GitHub → Jenkins → DockerHub → Deployment Target
```
Image 1: Architectural overview
![Image 1 – Architectural overview](images/1.overview.png)

### Step-by-step flow

1. A developer pushes code to GitHub.
2. GitHub sends a **webhook event** to the Jenkins server.
3. Jenkins receives the event and detects a change (delta) in the repository.
4. Jenkins checks out the latest version of the code.
5. Jenkins executes the **Declarative Pipeline** defined in the `Jenkinsfile`.
6. The pipeline:

   * Sets up the test environment
   * Runs tests
   * Builds a Docker image
   * Pushes the image to DockerHub
   * Deploys the application

The focus of this setup is a **microservice architecture**, where the application is packaged and deployed as a container.

---

# Pipeline Configuration

## Jenkins Configuration Steps

1. Install Jenkins on the local machine.
2. Install required plugins (Git, Docker, Pipeline, Credentials, SSH Agent).
3. Create a Jenkins pipeline job.
4. Configure the job to:

   * Use GitHub as the source repository
   * Load the pipeline definition from `Jenkinsfile`
5. Configure credentials (DockerHub, SSH, AWS if needed).


Image 2 – Jenkins job configuration
![Image 2 – Jenkins job configuration](images/1.overview.png)
---

# Webhook Configuration — Design Decision

## Problem Statement

Jenkins is running **locally on my laptop (LAN)** but GitHub is a **cloud service**.

So the key question is:

> How does GitHub reach a Jenkins server that is not publicly hosted?

---

## Initial Attempt: Router Port Forwarding

I initially configured **port forwarding** on my home router so that incoming HTTP traffic would be forwarded to the Jenkins machine.

However:

* Even after forwarding ports, Jenkins remained unreachable from the internet.
* Further investigation revealed that my **Internet Service Provider blocks all inbound traffic** except on:

  * HTTP (port 80)
  * HTTPS (port 443)

> Router port-forwarding configuration
One option would be to reconfigure jenkins to listen on any of these ports and then configure the portforwarding to it. I decided against using these specialized ports for jenkins.
---

## Final Solution: ngrok Tunneling

To work around ISP restrictions, I used **ngrok**, a tunneling service that exposes a local service through a secure public URL.

### Steps taken:

1. Registered on the ngrok website.
2. Obtained an authentication token.
3. Installed ngrok on my machine.
4. Started a tunnel:

```bash
ngrok http 8080
```

This produced a **public HTTPS URL** that forwards traffic directly to my local Jenkins server.

Image 2 – ngrok activating
![Image 2 – ngrok activating](images/1.overview.png)
📸 **Screenshot placeholder:**

> ngrok terminal showing public URL

---

## GitHub Webhook Configuration

The ngrok-generated URL was used as the **Webhook endpoint** in GitHub.

* Event type: `push`
* Payload URL: `https://<ngrok-id>.ngrok.io/github-webhook/`

Image 4 – Github-webhook-configuration
![Image 4 – Github-webhook-configuration](images/1.overview.png)

> GitHub webhook configuration page

> ⚠️ Note: ngrok must be restarted after a system reboot, as the URL changes.

---

# Testing the Webhook Integration

### Test Steps

```bash
git add .
git commit -m "test webhook"
git push origin master
```

### Result

1. GitHub receives the push.
2. GitHub fires a webhook event.
3. Jenkins receives the event.
4. Jenkins triggers the pipeline execution.

The receipt of the webhook can be seen in:

* Jenkins build history
* GitHub webhook delivery logs
Image 5: Jenkins job triggered by github webhook 
![Image 5 – Github-webhook-Trigger event receipt by Jenkins confirmation](images/1.overview.png)

> Jenkins build triggered by GitHub webhook

---

# Declarative Pipeline Logic (Jenkinsfile)

## Pipeline Responsibilities

### 1. Prepare Python Test Environment

* Create a virtual environment
* Install dependencies from `requirements.txt`

### 2. Test the Application

* Execute unit tests using `pytest`
* Publish test results using JUnit reporting

### 3. Build Docker Image

* Build image using the `Dockerfile`
* Tag the image using the Jenkins build number

```bash
docker build -t egamor/jenkins-flask-app:${BUILD_NUMBER} .
```

### 4. Tag and Push to DockerHub

```bash
docker tag egamor/jenkins-flask-app:${BUILD_NUMBER} egamor/jenkins-flask-app:latest
docker push egamor/jenkins-flask-app:latest
```

---

## DockerHub Authentication

Pushing to DockerHub requires authentication.

* DockerHub credentials are stored **securely in Jenkins Credentials Manager**
* Credentials are injected at runtime using `withCredentials`
* Passwords are masked in logs

Several credential storage options exist in Jenkins (discussed later).

To preserve logs for troubleshooting, `archiveArtifacts` is used.

Image 6: dockerhub authentication configuration on Jenkins
![Image 6 – dockerhub authentication configuration on Jenkins](images/1.overview.png)

Image 7: Login into dockerhub account on the pipeline script
![Image 7: Login into dockerhub account on the pipeline script](images/some.png) 

📸 **Screenshot placeholder:**

---

# Deployment Strategy

## Local Deployment

* Application is deployed locally using:

```bash
docker run -d -p 5000:5000 egamor/jenkins-flask-app:latest
```

* Container status verified using:

```bash
docker ps
```

---

## Remote Deployment on EC2

Jenkins running locally **cannot deploy to EC2 without authentication**.

Some form of trust must exist between Jenkins and the EC2 instance.

---

## SSH-Based Deployment

I used **SSH authentication** for remote deployment.
I configured my ec2 to use AWS SSH key pairs.  I downloaded the private key and configured it on the Jenkins credentials. 

Image 8: ssh-key-configuration on Jenkins
![Image 8: ssh-key-configuration on Jenkins](images/something.png)

> Jenkins SSH credential configuration

This enabled my Jenkins to log onto the ec2 instance securely, and then download the docker image and run it. 
---
Test
---
Reminder: The goal: I want the whole pipeline of pre-build, testing app, building the docker image of the app, and deploying the app to happen automatically upon pushing of a new code in our SCM. 

So I made a change in our code, commit it to stage and then push it to github. 

# Results and Discussion

A webhook event was triggered and sent to the Jenkins as show in Image 9.

Image 9: ssh-key-configuration on Jenkins
![Image 9: ssh-key-configuration on Jenkins](images/something.png)
📸 **Screenshot placeholder:**

Jenkins executed all the stages successfully and deployed the application on Amazon EC2. 

The successfully deployment was evident in the pipeline logs and confirmed with a docker ps -a command on ec2.

* The application was accessible via the exposed port.
The successful deployment was also confirmed by visiting the page deployed. Image 10 is a screenhot of the app.

Image 10: app opened on ec2
![Image 10: app opened on ec2](images/something.png)

---

# Credential Storage Options in Jenkins

* Username & password
* Secret text
* SSH private key
* AWS credentials
* Token-based authentication

Each option controls **how credentials are injected and masked** in pipelines.

---

# Skills demonstrated

* Complete automation of CI/CD workflow using Jenkins declarative pipeline
* Configuring Github Webhooks to trigger and automatically run pipeline jobs on push. 
* Using ngrok for local CI experimentation.
* Handling Credentials Jenkins and using same in declarative pipeline script. 

---

# Installed Jenkins Plugins

* Git Plugin
* Pipeline Plugin
* Docker Pipeline
* Credentials Binding
* SSH Agent
* JUnit Plugin

---
---
