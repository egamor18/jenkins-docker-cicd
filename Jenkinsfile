pipeline {
    agent any

    environment {
        VENV = "venv"
        IMAGE_NAME = "egamor/jenkins-flask-app"
        TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }
/*
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
        // troubleshooting purposes
        stage('Debug Branch') {
            steps {
                sh 'echo BRANCH_NAME=$BRANCH_NAME'
            }
        }
*/

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${TAG} .
                '''
                echo 'DOCKER IMAGE BUILD SUCCESSFUL'

                sh '''
                    ls
                '''
            }
        }

        stage('Push Docker Image') {
            /*
            when {
                branch 'master'
            } 
            */

            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    echo ' about to login into dockerhub ....'
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

                        #check login status. sucessful or failure
                        #docker info | grep username


                        set -e
                        docker push ${IMAGE_NAME}:${TAG}
                        docker tag ${IMAGE_NAME}:${TAG} ${IMAGE_NAME}:latest
                        docker push ${IMAGE_NAME}:latest
                        echo "All Docker operations succeeded"

                    '''
                }
            }
        }

        /*
        stage('Deploy') {
            
            when {
                branch 'master'
            }
            
            steps {
                sh '''
                    echo "Deploying Flask app..."
                    # Example deploy: restart Docker container on server
                    # ssh user@server "docker pull ${IMAGE_NAME}:latest && docker stop flask-app && docker run -d --name flask-app -p 5000:5000 ${IMAGE_NAME}:latest"
                '''
            }
        }
        */
    }
}
