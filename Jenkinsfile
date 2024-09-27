pipeline {
  agent any
  environment {
    AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
  }
  stages {
    stage('Clone repository') {
      steps {
        git 'https://github.com/PradeepKumar8765/react-helloworld.git'
      }
    }

    stage('Install dependencies') {
      steps {
        sh 'npm install'
      }
    }

    stage('Build the project') {
      steps {
        sh 'npm run build'
      }
    }

    stage('Run tests') {
      steps {
        sh 'npm test'
      }
    }

    stage('Build Docker image') {
      steps {
        script {
          sh 'docker build -t pradeep82kumar/react-app:v1 .'
        }
      }
    }

    stage('Push Docker image to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
          sh "echo $PASS | docker login -u $USER --password-stdin"
          sh 'docker push pradeep82kumar/react-app:v1'
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        script {
          sh 'aws eks update-kubeconfig --region us-east-1 --name prod-cluster'
          sh 'kubectl apply -f app-deployment.yml'
        }
      }
    }
  }

  post {
    always {
      cleanWs()
    }
    success {
      echo 'Build and deployment successful!'
    }
    failure {
      echo 'Build or deployment failed!'
    }
  }
}
