pipeline {
    agent { label 'jenkins-agent' }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '529088274428'
        ECR_BACKEND = "inventory-backend"
        ECR_FRONTEND = "inventory-frontend"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                script {
                    // Use short Git commit hash as image tag
                    env.IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "IMAGE_TAG = ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform') {
                    withCredentials([usernamePassword(
                        credentialsId: 'aws-creds',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )]) {
                        sh '''
                            terraform init -input=false
                            terraform fmt -check
                            terraform validate
                        '''
                    }
                }
            }
        }

        stage('Build & Push Backend') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-creds',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    sh '''
                        echo "Logging into ECR (backend)..."
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com

                        echo "Building backend Docker image..."
                        docker build -t $ECR_BACKEND:$IMAGE_TAG backend
                        docker tag $ECR_BACKEND:$IMAGE_TAG ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_BACKEND:$IMAGE_TAG
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_BACKEND:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Build & Push Frontend') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-creds',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    sh '''
                        echo "Logging into ECR (frontend)..."
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com

                        echo "Building frontend Docker image..."
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
                    withCredentials([usernamePassword(
                        credentialsId: 'aws-creds',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )]) {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Deploy ECS') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-creds',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
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
            echo " Deployment successful! Backend and Frontend updated."
        }
        failure {
            echo " Deployment failed. Check logs for details."
        }
    }
}
