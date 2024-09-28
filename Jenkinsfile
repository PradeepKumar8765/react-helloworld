pipeline {
  agent any
  stages {
    stage('Clone the project') {
      steps {
        git 'https://github.com/PradeepKumar8765/react-helloworld.git'
      }
    }
    stage('Build Docker image') {
      steps {
        script {
          sh 'docker build -t pradeep82kumar/react-app:v1 .'
          sh 'docker images'
        }
      }
    }
    stage('Push to Docker Hub') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentials', accessKey: 'aws-access-key', secretKey: 'aws-secret-key']]) {
          sh "echo $PASS | docker login -u $USER --password-stdin"
          sh 'docker push pradeep82kumar/react-app:v1'
        }
      }
    }
    stage('Terraform Operations for test workspace') {
      steps {
        script {
         withCredentials([[$class: 'AmazonWebServicesCredentials', accessKey: 'aws-access-key', secretKey: 'aws-secret-key']]) {
            sh '''
              terraform workspace select test || terraform workspace new test
              terraform init
              terraform plan
              terraform destroy -auto-approve
            '''
          }
        }
      }
    }
    stage('Terraform apply for test workspace') {
      steps {
       withCredentials([[$class: 'AmazonWebServicesCredentials', accessKey: 'aws-access-key', secretKey: 'aws-secret-key']]) {
          sh 'terraform apply -auto-approve'
        }
      }
    }
    stage('Get kubeconfig for test') {
      steps {
      withCredentials([[$class: 'AmazonWebServicesCredentials', accessKey: 'aws-access-key', secretKey: 'aws-secret-key']]) {
          sh 'aws eks update-kubeconfig --region us-east-1 --name test-cluster'
          sh 'kubectl get nodes'
        }
      }
    }
    stage('Deploy the application to test') {
      steps {
        sh 'kubectl apply -f app-deploy.yml'
        sh 'kubectl get svc'
      }
    }
    stage('Terraform Operations for Production workspace') {
      when {
        expression {
          return currentBuild.currentResult == 'SUCCESS'
        }
      }
      steps {
        script {
         withCredentials([[$class: 'AmazonWebServicesCredentials', accessKey: 'aws-access-key', secretKey: 'aws-secret-key']]){
            sh '''
              terraform workspace select prod || terraform workspace new prod
              terraform init
              terraform plan
              terraform destroy -auto-approve
            '''
          }
        }
      }
    }
    stage('Terraform apply for production workspace') {
      steps {
       withCredentials([[$class: 'AmazonWebServicesCredentials', accessKey: 'aws-access-key', secretKey: 'aws-secret-key']]) {
          sh 'terraform apply -auto-approve'
        }
      }
    }
    stage('Get kubeconfig for production') {
      steps {
       withCredentials([[$class: 'AmazonWebServicesCredentials', accessKey: 'aws-access-key', secretKey: 'aws-secret-key']]) {
          sh 'aws eks update-kubeconfig --region us-east-1 --name prod-cluster'
          sh 'kubectl get nodes'
        }
      }
    }
    stage('Deploy the application to production') {
      steps {
        sh 'kubectl apply -f app-deploy.yml'
        sh 'kubectl get svc'
      }
    }
  }
}

