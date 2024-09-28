pipeline {
  agent any
  stages {
    stage('build the project') {
      steps {
        git 'https://github.com/PradeepKumar8765/react-helloworld.git'
        sh 'mvn clean package'
      }
    }
    stage('Building docker image') {
      steps {
        script {
          sh 'docker build -t pradeep82kumar/react-app:v1 .'
          sh 'docker images'
        }
      }
    }
    stage('push to docker-hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
          sh "echo $PASS | docker login -u $USER --password-stdin"
          sh 'pradeepkumar/react-app:v1'
        }
      }
    }
    stage('Terraform Operations for test workspace') {
      steps {
        script {
          withCredentials([amazonWebServicesCredentials(credentialsId: 'aws-credentials')]) {
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
    stage('Terraform destroy & apply for test workspace') {
      steps {
        withCredentials([amazonWebServicesCredentials(credentialsId: 'aws-credentials')]) {
          sh 'terraform apply -auto-approve'
        }
      }
    }
    stage('get kubeconfig') {
      steps {
        withCredentials([amazonWebServicesCredentials(credentialsId: 'aws-credentials')]) {
          sh 'aws eks update-kubeconfig --region us-east-1 --name test-cluster'
          sh 'kubectl get nodes'
        }
      }
    }
    stage('Deploying the application') {
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
          withCredentials([amazonWebServicesCredentials(credentialsId: 'aws-credentials')]) {
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
    stage('Terraform destroy & apply for production workspace') {
      steps {
        withCredentials([amazonWebServicesCredentials(credentialsId: 'aws-credentials')]) {
          sh 'terraform apply -auto-approve'
        }
      }
    }
    stage('get kubeconfig for production') {
      steps {
        withCredentials([amazonWebServicesCredentials(credentialsId: 'aws-credentials')]) {
          sh 'aws eks update-kubeconfig --region us-east-1 --name prod-cluster'
          sh 'kubectl get nodes'
        }
      }
    }
    stage('Deploying the application to production') {
      steps {
        sh 'kubectl apply -f app-deploy.yml'
        sh 'kubectl get svc'
      }
    }
  }
}
