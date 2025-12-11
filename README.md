# 3-Tier-Infrastructure-Using-Terraform

# Overview :

* This project implements a highly scalable and production-ready 3-tier architecture on Amazon Web Services (AWS) using Infrastructure as Code (IaC) with Terraform.

* The goal is to design and provision a secure, modular, and cloud-optimized infrastructure that follows AWS best practices.

# Features :

* Fully Automated Infrastructure (IaC)

* Secure Networking Setup

# Architecture 

1) Web Tier 

* Public Subnet

* Internet Gateway

* Web Server (EC2)

* Security Group allows HTTP (80) & SSH (22)

2) App Tier 

* Private App Subnet

* App Server (EC2)

* Security Group allows traffic only from Web Tier

3) Database Tier

* Private DB Subnet

* DB Server (EC2)

* Security Group allows traffic only from App Tier

* Networking

* NAT Gateway in Public Subnet

* Private subnets route internet access via NAT

* Separate route tables for Public & Private tiers

# Project Structure

3-Tier-infrastructure-using-terraform /

│── main.tf

│── variables.tf

│── outputs.tf

│── provider.tf 

│── README.md

└── .gitignore

# deploy steps :

     terraform init

![Architecture](images/Screenshot%20(143).png)

    terraform plan

![Architecture](images/Screenshot%20(144).png)

    terraform apply --auto-approve

![Architecture](images/Screenshot%20(145).png)

# Output of terraform :

## 1. vpc :

![Architecture](images/Screenshot%20(146).png)

## 2. Subnet :
 
 ![Architecture](images/Screenshot%20(147).png)

 ## 3. Route Table :

 ![Architecture](images/Screenshot%20(148).png)

 ## 4. Internet Gateway :

 ![Architecture](images/Screenshot%20(149).png)

 ## 5. output :

 ![Architecture](images/Screenshot%20(150).png)

# outcomes :

* Successfully launched a 3-tier AWS infrastructure using Terraform

* Automated provisioning of VPC, subnets, NAT, EC2, security groups, and EIP

* Improved deployment speed and reduced manual errors using IaC (Infrastructure as Code)

* Gained hands-on experience with Terraform modules, variables, outputs, and state management

* Learned how to scale and manage cloud infrastructure efficiently


