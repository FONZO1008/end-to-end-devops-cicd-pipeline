pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO = 'my-app'
        ACCOUNT_ID = '303192503865'
        IMAGE_TAG = "${BUILD_NUMBER}"
        IMAGE_URI = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/FONZO1008/end-to-end-devops-cicd-pipeline.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-app .'
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {

                    sh '''
                    aws ecr get-login-password --region $AWS_REGION \
                    | docker login --username AWS --password-stdin \
                    $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Tag & Push to ECR') {
            steps {
                sh '''
                docker tag my-app:latest $IMAGE_URI
                docker push $IMAGE_URI
                '''
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init
                    terraform apply -auto-approve \
                    -var="image_tag=$IMAGE_TAG"
                    '''
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
                    echo "$EC2_IP ansible_user=ec2-user ansible_ssh_private_key_file=$SSH_KEY" >> ansible/inventory

                    ansible-playbook -i ansible/inventory ansible/deploy.yml \
                    --extra-vars "image_uri=$IMAGE_URI"
                    '''
                }
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                sleep 15
                curl -f http://$EC2_IP:3000/health
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
