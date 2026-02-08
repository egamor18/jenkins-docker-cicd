pipeline {
    agent any

    environment {
        VENV = "venv"
        IMAGE_NAME = "egamor/jenkins-flask-app"
        //TAG = "${BUILD_NUMBER}"
        TAG = 3
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
                    pip install -q --upgrade pip
                    pip install -q -r requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    . ${VENV}/bin/activate
                    pytest --junitxml=test-results.xml > test.log 2>&1 || true
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


        stage('Build Docker Image') {
            steps {
                sh '''
                    #docker build -t ${IMAGE_NAME}:${TAG} .


                    docker build -t ${IMAGE_NAME}:${TAG} . > build.log 2>&1 || {
                            echo "Build failed"
                            cat build.log
                            exit 1
                    }

                '''
                //lets archive the artifacts
                archiveArtifacts artifacts: 'build.log', fingerprint: true

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

                    sh '''
                        echo "Logging into Docker..."
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin || exit 1

                        #redirect the output to push.log and display error upon failure
                        docker push ${IMAGE_NAME}:${TAG} > push.log 2>&1 || {
                            echo "Push failed"
                            cat push.log
                            exit 1
                        }

                        docker tag ${IMAGE_NAME}:${TAG} ${IMAGE_NAME}:latest
                        docker push ${IMAGE_NAME}:latest >> push.log 2>&1 || {
                            echo "Latest push failed"
                            cat push.log
                            exit 1
                        }

                        echo "Docker push successful"
                    '''
                    //to save the logs
                    archiveArtifacts artifacts: 'push.log'

                }
            }
        }

    stage('Deploy') {
        
        steps {
            sshagent(credentials: ['server-ssh-key']) {
                sh """
                ssh -o StrictHostKeyChecking=no ubuntu@ec2-52-59-219-191.eu-central-1.compute.amazonaws.com '
                    docker pull egamor/jenkins-flask-app:latest &&
                    docker stop flask-app || true &&
                    docker rm flask-app || true &&
                    docker run -d --name flask-app -p 5000:5000 egamor/jenkins-flask-app:latest
                '
                """
            }
        }
    }


}



