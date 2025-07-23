# 🚀 Terraform AWS Infrastructure Setup

This project demonstrates how to provision a complete cloud infrastructure on AWS using **Terraform**. The setup includes VPC creation, networking components, a security group, and deploying an Ubuntu EC2 instance with Apache2 pre-installed.

---

## 🧱 Project Overview

### 🌐 Infrastructure Components
The following AWS resources are created using Terraform:
- VPC with a custom CIDR block
- Internet Gateway and Route Table
- Public Subnet
- Security Group (allowing ports **22**, **80**, and **443**)
- Elastic IP (EIP)
- Network Interface
- Ubuntu EC2 instance with **Apache2** pre-installed

---

## 📋 Project Steps

1. **Create a VPC** with a defined CIDR block  
2. **Attach an Internet Gateway** to the VPC  
3. **Create and associate a custom Route Table**  
4. **Create a Public Subnet**  
5. **Associate the subnet** with the route table  
6. **Define a Security Group** to allow SSH, HTTP, and HTTPS  
7. **Launch a Network Interface** within the subnet  
8. **Allocate an Elastic IP** and associate it with the network interface  
9. **Provision an Ubuntu EC2 instance** and install **Apache2**

---

## 📁 File Structure

```bash
.
├── main.tf                 # Main Terraform configuration
├── project.tf             # Additional modular Terraform logic
├── terraform.tfstate      # Terraform state (auto-generated)
├── terraform.tfstate.backup
├── Notes.txt              # Terraform concepts and operational guidance
├── project-notes.txt      # Ordered step-by-step resource creation
└── project-access-key.pem # SSH Key for EC2 (DO NOT COMMIT PUBLICLY)
