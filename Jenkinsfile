pipeline {
    agent any
    
    stages {
        stage('Log into AWS ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ap-southeast-2 | sudo docker login --username AWS --password-stdin 796714792116.dkr.ecr.ap-southeast-2.amazonaws.com"
                } 
            }
        }
        
        stage('Build image') {
            steps{
                script {
                    sh "sudo docker build -t servian-app-ecr-repo ."
                }
            }
        }
        
        stage('Tag image'){
            steps{
                script{
                    sh "sudo docker tag servian-app-ecr-repo:latest 796714792116.dkr.ecr.ap-southeast-2.amazonaws.com/servian-app-ecr-repo:latest"
                }
            }
        }

        stage('Pushing to ECR') {
            steps{  
                script {
                    sh "sudo docker push 796714792116.dkr.ecr.ap-southeast-2.amazonaws.com/servian-app-ecr-repo:latest"
                }
            }
        }
    }
}