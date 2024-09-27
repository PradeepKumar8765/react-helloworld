pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Clone the repository
                    git 'https://github.com/PradeepKumar8765/react-helloworld.git'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh 'docker build -t pradeep82kumar/react-app:v1 .'
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        // Log in to Docker Hub
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        // Push the Docker image to Docker Hub
                        sh 'docker push pradeep82kumar/react-app:v1'
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        // Update kubeconfig for the EKS cluster
                        sh 'aws eks update-kubeconfig --region $AWS_REGION --name prod-cluster'
                        // Deploy the application using kubectl
                        sh 'kubectl apply -f app-deployment.yml'
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up the workspace after the build
            cleanWs()
        }
        success {
            // Message on successful build and deployment
            echo 'Build and deployment successful!'
        }
        failure {
            // Message on failure
            echo 'Build or deployment failed!'
        }
    }
}
