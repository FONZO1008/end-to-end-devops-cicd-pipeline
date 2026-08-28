pipeline {
    agent any

    environment {
        IMAGE_TAG    = "${BUILD_NUMBER}"
        ECR_REGISTRY = "303192503865.dkr.ecr.ap-south-1.amazonaws.com"
        ECR_REPO     = "my-app"
        AWS_REGION   = "ap-south-1"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Taneshbad/end-to-end-devops-cicd-pipeline.git'
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                pip install -r requirements.txt --quiet
                pytest --tb=short || true
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${ECR_REPO}:${IMAGE_TAG} .'
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REGISTRY}

                    docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}
                    docker push ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    dir('terraform') {
                        sh '''
                        terraform init
                        terraform apply -auto-approve \
                          -var="image_tag=${IMAGE_TAG}"
                        '''
                    }
                }
            }
        }

        stage('Get EC2 Public IP') {
            steps {
                script {
                    env.EC2_IP = sh(
                        script: "cd terraform && terraform output -raw public_ip",
                        returnStdout: true
                    ).trim()
                    echo "EC2 IP: ${env.EC2_IP}"
                }
            }
        }

        stage('Run Ansible Deployment') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )
                ]) {
                    sh '''
                    echo "[app]" > ansible/inventory
                    echo "${EC2_IP} ansible_user=ec2-user ansible_ssh_private_key_file=${SSH_KEY}" >> ansible/inventory

                    ansible-playbook -i ansible/inventory ansible/deploy.yml \
                      --extra-vars "image_tag=${IMAGE_TAG}"
                    '''
                }
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                echo "Waiting for app to be ready..."
                for i in $(seq 1 12); do
                    if curl -sf http://${EC2_IP}:3000/health; then
                        echo "Health check passed on attempt $i"
                        exit 0
                    fi
                    echo "Attempt $i failed, retrying in 10s..."
                    sleep 10
                done
                echo "Health check failed after all attempts"
                exit 1
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Deployment Successful!'
        }
        failure {
            echo '❌ Deployment Failed!'
        }
    }
}
