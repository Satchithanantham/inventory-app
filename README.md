# Inventory Management Application – Full Stack DevOps Project

# Overview
This project is a **Full-Stack DevOps implementation** for an Inventory Management System designed for warehouse operations.  
It demonstrates **end-to-end DevOps capabilities**, including infrastructure provisioning, CI/CD automation, containerized application deployment, security, and monitoring on **AWS**.

The application allows users to:
- View Books
- Add new Books
- Edit Books
- Delete Books

The application consists of:
- **Frontend**: React-based web dashboard
- **Backend**: Node.js REST API
- **Database**: AWS RDS (MySQL)
- **Deployment**: AWS ECS (Fargate)
- **CI/CD**: Jenkins Pipeline
- **Infrastructure**: Terraform (modular)
- **Security & Monitoring**: IAM, WAF, CloudWatch, SNS

# Architecture Overview

**High-level flow:**

Users → ALB → AWS WAF
├── /api/* → Backend ECS Service
└── / → Frontend ECS Service
Backend → RDS (Private Subnet)
Logs → CloudWatch
ALB Logs → S3
Alerts → SNS (Email)

# Technology Stack

| Layer | Technology |
|------|-----------|
| Frontend | React |
| Backend | Node.js / Express |
| Database | AWS RDS (MySQL) |
| Containerization | Docker |
| Orchestration | AWS ECS (Fargate) |
| Load Balancer | Application Load Balancer |
| IaC | Terraform |
| CI/CD | Jenkins |
| Security | IAM, AWS WAF, Security Groups |
| Monitoring | CloudWatch, SNS |
| Logs | CloudWatch Logs, S3 |

# Repository Structure

INVENTORY APP/
├── Backend/
│ ├── app.js
│ ├── db.js
│ ├── package.json
│ └── dockerfile
│
├── Frontend/
│ ├── public/
│ ├── src/
│ │ ├── services/
│ │ ├── app.js
│ │ └── index.js
│ ├── nginx.conf
│ ├── package.json
│ └── dockerfile
│
├── Terraform/
│ ├── .terraform/
│ ├── modules/
│ │ ├── alb
│ │ ├── cloudwatch
│ │ ├── cloudwatch_alarms
│ │ ├── dns
│ │ ├── ecr
│ │ ├── ecs
│ │ ├── iam
│ │ ├── rds
│ │ ├── s3_logs
│ │ ├── secrets
│ │ └── waf
│ ├── backend.tf
│ ├── providers.tf
│ ├── variables.tf
│ ├── terraform.tfvars
│ ├── outputs.tf
│ └── main.tf
│
└── README.md

# Features Implemented

## Infrastructure (Terraform)
- Modular Terraform design
- Remote Terraform state stored in **S3** with **DynamoDB state locking** to prevent concurrent runs
- ECS Cluster (Fargate)
- Application Load Balancer with path-based routing
- AWS WAF attached to ALB
- RDS MySQL in private subnets
- ECR repositories for frontend & backend
- S3 bucket for ALB access logs
- IAM roles with least privilege
- CloudWatch Log Groups
- CloudWatch Alarms (CPU, Memory, ALB 5xx)
- SNS notifications for alerts

# Application
## Backend API (Node.js)
- RESTful endpoints:
  - `GET /api/books`
  - `POST /api/books`
  - `PUT /api/books/:id`
  - `DELETE /api/books/:id`
- Uses environment variables:
  - `DB_HOST`
  - `DB_USER`
  - `DB_PASS`
  - `DB_NAME`
- Exposes port `5000`

## Frontend (React)
- Books dashboard
- CRUD operations
- Communicates with backend via ALB
- Exposes port `3000`

# CI/CD Pipeline (Jenkins)

## Pipeline Workflow
1. Triggered on push to `main`
2. Terraform formatting & validation
3. Docker image build (frontend & backend)
4. Push images to AWS ECR
5. Terraform apply (infra changes)
6. ECS service update (rolling deployment)

# Jenkins → AWS Authentication (Important)

## No AWS credentials stored in Jenkins

- Jenkins runs on an **EC2 instance**
- An **IAM Role** is attached to the EC2 instance
- AWS credentials are provided automatically via **Instance Metadata Service (IMDS)**
- Terraform, AWS CLI, and SDKs use temporary credentials

**Benefits**
- No hardcoded secrets
- Automatic credential rotation
- Least-privilege access
- Fully auditable via CloudTrail

# Security

- AWS WAF with:
  - SQL Injection protection
  - AWS managed rule sets
  - IP reputation filtering
- ECS Security Groups:
  - Backend accessible only via ALB
  - Database accessible only from ECS
- Private RDS subnets
- S3 buckets with restrictive bucket policies
- IAM roles with least-privilege access

# Monitoring & Logging

- CloudWatch Logs for:
  - Frontend containers
  - Backend containers
- ALB access logs stored in S3
- CloudWatch Alarms:
  - ECS CPU > 80%
  - ECS Memory > 80%
  - ALB 5xx errors
- SNS Email notifications for alerts

# How to Deploy

## Prerequisites
- AWS Account
- Terraform ≥ 1.x
- Docker
- Jenkins
- AWS CLI configured

### Steps
```bash
cd Terraform
terraform init
terraform plan
terraform apply
