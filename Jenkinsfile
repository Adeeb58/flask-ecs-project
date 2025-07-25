// The Jenkinsfile defines the CI/CD pipeline
pipeline {
    // Run this pipeline on any available Jenkins agent
    agent any

    // Environment variables used throughout the pipeline
    environment {
        // IMPORTANT: Replace this with your ECR URI
        ECR_REGISTRY_URI = "public.ecr.aws/g9j0e3q3/flask-app"
        AWS_REGION       = "us-east-1"
    }

    // The pipeline is composed of different stages
    stages {
        // Stage 1: Build the Docker image from our Dockerfile
        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker image...'
                // The 'sh' step executes a shell command
                sh 'docker build -t flask-app:latest .'
            }
        }

        // Stage 2: Log in to the AWS ECR Public registry
        stage('Login to AWS ECR') {
            steps {
                echo 'Logging in to Amazon ECR...'
                // This 'withCredentials' block securely provides the credentials we stored in Jenkins
                // to the commands inside it. 'aws-credentials' is the ID we set up.
                withCredentials([aws(credentialsId: 'aws-credentials', region: AWS_REGION)]) {
                    sh "aws ecr-public get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin public.ecr.aws"
                }
            }
        }

        // Stage 3: Tag and Push the image to ECR
        stage('Push Image to ECR') {
            steps {
                echo "Tagging image with: ${public.ecr.aws/g9j0e3q3/flask-app}:latest"
                sh "docker tag flask-app:latest ${public.ecr.aws/g9j0e3q3/flask-app}:latest"

                echo "Pushing image to ECR..."
                sh "docker push ${Epublic.ecr.aws/g9j0e3q3/flask-app}:latest"
            }
        }
    }
}