pipeline {
    agent { label 'jenkins-agent' }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '529088274428'
        ECR_BACKEND = "inventory-backend"
        ECR_FRONTEND = "inventory-frontend"
        IMAGE_TAG = "${env.GIT_COMMIT?.take(7)}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform') {
                    sh '''
                        terraform init -input=false
                        terraform fmt -check
                        terraform validate
                    '''
                }
            }
        }

        stage('Build & Push Backend') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com

                        docker build -t $ECR_BACKEND:$IMAGE_TAG backend
                        docker tag $ECR_BACKEND:$IMAGE_TAG ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_BACKEND:$IMAGE_TAG
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_BACKEND:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Build & Push Frontend') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        docker build -t $ECR_FRONTEND:$IMAGE_TAG frontend
                        docker tag $ECR_FRONTEND:$IMAGE_TAG ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_FRONTEND:$IMAGE_TAG
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_FRONTEND:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Deploy ECS') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    script {
                        parallel(
                            backend: {
                                sh 'aws ecs update-service --cluster inventory-cluster --service inventory-api --force-new-deployment'
                            },
                            frontend: {
                                sh 'aws ecs update-service --cluster inventory-cluster --service inventory-frontend --force-new-deployment'
                            }
                        )
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful! Backend and Frontend are updated."
        }
        failure {
            echo "Deployment failed. Check logs."
        }
    }
}
