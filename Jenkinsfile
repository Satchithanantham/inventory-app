pipeline {
    agent { label 'jenkins-agent' }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '529088274428'
        ECR_BACKEND = "inventory-backend"
        ECR_FRONTEND = "inventory-frontend"
        SONAR_TOKEN = credentials('jenkins-sonar-token')
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

        stage('Debug Workspace') {
            steps {
                echo "Listing workspace contents..."
                sh 'pwd'
                sh 'ls -l'
            }
        }

       
        stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('sonarcloud') {
            script {
                def scannerHome = tool 'SonarScanner' 
                sh "${scannerHome}/bin/sonar-scanner \
                    -Dsonar.organization=satchithanantham \
                    -Dsonar.projectKey=satchithanantham_inventory-app \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=$SONAR_HOST_URL \
                    -Dsonar.login=$SONAR_TOKEN"
            }
        }
    }
}


      
        stage('Quality Gate') {
            when {
                branch 'main'
            }
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('Terraform') {
                    sh '''
                        terraform init -input=false
                        terraform fmt -check
                        terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('Terraform') {
                    sh 'terraform plan -var-file=terraform.tfvars'
                }
            }
        }

        stage('Approval') {
            steps {
                input message: "Approve to continue?",
                      ok: "Yes, continue",
                      submitter: "admin,devops"
            }
        }

        stage('Build & Push Backend') {
            steps {
                sh '''
                    echo "Logging into ECR (backend)..."
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com

                    echo "Building backend Docker image..."
                    docker build -t $ECR_BACKEND:$IMAGE_TAG Backend
                    docker tag $ECR_BACKEND:$IMAGE_TAG ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_BACKEND:$IMAGE_TAG
                    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_BACKEND:$IMAGE_TAG
                '''
            }
        }

        stage('Build & Push Frontend') {
            steps {
                sh '''
                    echo "Logging into ECR (frontend)..."
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com

                    echo "Building frontend Docker image..."
                    docker build -t $ECR_FRONTEND:$IMAGE_TAG Frontend
                    docker tag $ECR_FRONTEND:$IMAGE_TAG ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_FRONTEND:$IMAGE_TAG
                    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_FRONTEND:$IMAGE_TAG
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('Terraform') {
                    sh 'terraform apply -auto-approve -lock=false -var-file=terraform.tfvars'
                }
            }
        }

        stage('Deploy ECS') {
            steps {
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

    post {
        success {
            echo "Deployment successful! Backend and Frontend updated."
        }
        failure {
            echo "Deployment failed. Check logs for details."
        }
    }
}
