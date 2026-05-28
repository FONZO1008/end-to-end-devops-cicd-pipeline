# 🚀 End-to-End DevOps CI/CD Pipeline (AWS)

🔗 Repo: https://github.com/Taneshbad/end-to-end-devops-cicd-pipeline

---

## 📌 Overview

This project implements a **complete DevOps CI/CD pipeline** that automates application deployment from source code to a live server on AWS EC2.

It demonstrates real-world DevOps practices including:

* Continuous Integration (CI)
* Continuous Deployment (CD)
* Infrastructure as Code (IaC)
* Configuration Management

---

## 🎯 Problem Statement

Traditional deployments are:

* Manual and slow
* Error-prone
* Difficult to reproduce
* No rollback capability

👉 This project solves these issues by automating the entire pipeline.

---

## 🛠️ Tech Stack

| Category          | Tools                   |
| ----------------- | ----------------------- |
| CI/CD             | Jenkins, GitHub Actions |
| Containerization  | Docker                  |
| Cloud             | AWS EC2                 |
| IaC               | Terraform               |
| Config Management | Ansible                 |
| Version Control   | GitHub                  |

---

## ⚙️ Architecture

```id="c64df8"
Developer → GitHub → Jenkins → Docker → Terraform → Ansible → AWS EC2 → Live App
```

---

## 🔁 Pipeline Workflow

1. Developer pushes code to GitHub
2. GitHub triggers Jenkins pipeline
3. Jenkins:

   * Clones repository
   * Builds Docker image
   * Runs container
4. Terraform provisions AWS infrastructure
5. Ansible configures server & deploys app
6. Application becomes live

---

## 📁 Project Structure

```id="2hy47d"
.
├── app/                 # Node.js application
├── Dockerfile           # Docker configuration
├── Jenkinsfile          # CI/CD pipeline
│
├── terraform/           # Infrastructure provisioning
├── ansible/             # Deployment automation
│
└── .github/workflows/   # GitHub Actions
```

---

## 🐳 Docker

Build & Run locally:

```id="z7pf2c"
docker build -t my-app .
docker run -p 3000:3000 my-app
```

---

## ⚙️ Jenkins Setup

1. Install Jenkins on EC2
2. Open:

```id="d7p2gb"
http://<EC2-IP>:8080
```

3. Configure pipeline using Jenkinsfile

---

## ☁️ Terraform

```id="m9ksgk"
cd terraform
terraform init
terraform apply
```

---

## 🔧 Ansible

```id="vd34nb"
cd ansible
ansible-playbook -i inventory deploy.yml
```

---

## 🌐 Access Application

```id="kmp9wy"
http://<EC2-PUBLIC-IP>:3000
```

Health Check:

```id="b0gk2k"
http://<EC2-IP>:3000/health
```

---

## 🔄 Rollback Strategy

* Stop current container
* Deploy previous Docker image
* Ensures minimal downtime

---

## 🚀 Features

* Automated CI/CD pipeline
* Dockerized application
* Infrastructure as Code
* Automated deployment
* Scalable architecture

---

## 📸 Screenshots (Add These!)

👉 Add screenshots of:

* Jenkins pipeline success
* EC2 running app
* Terminal deployment logs

---

## 📈 Future Enhancements

* SonarQube integration
* Blue/Green deployment
* Canary deployment
* Kubernetes (EKS)
* Monitoring (CloudWatch)

---

## 👨‍💻 Author

**Tanesh Badnore**

---

## ⭐ Show your support

If you like this project, give it a ⭐!
