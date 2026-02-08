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
                archiveArtifacts artifacts: build.log

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
                sh '''
                    echo "Deploying Flask app locally..."

                    CONTAINER_NAME="flask-app"

                    # Stop existing container if running
                    if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
                        echo "Stopping existing container..."
                        docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME
                    fi

                    # Run new container
                    docker run -d --name $CONTAINER_NAME -p 5000:5000 ${IMAGE_NAME}:latest

                    # Optional: check if container started
                    if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
                        echo "Deployment successful!"
                    else
                        echo "Deployment failed!"
                        exit 1
                    fi
                '''
            }
        }

    }

}

