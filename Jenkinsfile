pipeline {
    agent any

    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
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
                sh 'docker build -t my-app:${IMAGE_TAG} .'
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
                    --extra-vars "image_tag=$IMAGE_TAG"
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
