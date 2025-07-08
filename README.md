# EC2-Hosted Website with Terraform

This project uses Terraform to provision an Ubuntu EC2 instance on AWS, install Nginx, download a website template from Tooplate, and host it. The instance is secured with a security group that allows HTTP access from anywhere.

---

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [AWS Configuration](#aws-configuration)
- [Getting the Latest Ubuntu AMI ID](#getting-the-latest-ubuntu-ami-id)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Cleaning Up](#cleaning-up)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Features

- Launches an Ubuntu EC2 instance.
- Installs Nginx automatically.
- Downloads and unzips a Tooplate website template.
- Hosts the website on the EC2 instance.
- Configures a security group to allow HTTP (port 80) access from anywhere.

---

## Prerequisites

- **AWS Account**: You need an AWS account with permissions to create EC2 instances and security groups.
- **AWS CLI**: Install and configure the AWS CLI.
- **Terraform**: Install Terraform (v1.0+ recommended).

### Install AWS CLI

```sh
# macOS
brew install awscli

# Ubuntu
sudo apt-get install awscli
```

### Install Terraform

```sh
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Ubuntu
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

---

## AWS IAM User and Permissions

To use the AWS CLI and Terraform with your AWS account, you should create an IAM user with programmatic access and the necessary permissions:

1. Go to the AWS Console → IAM → Users → Add user.
2. Enter a username (e.g., `terraform-user`).
3. Select **Programmatic access**.
   - If you did not select Programmatic access during user creation, you can still generate access keys for CLI use later by going to the IAM user page, selecting the user, and choosing 'Create access key' under the Security credentials tab.
4. Attach the following permissions:
   - `AmazonEC2FullAccess` (for EC2 management)
   - `AmazonVPCFullAccess` (for networking, if needed)
   - `IAMReadOnlyAccess` (for reading IAM resources)
   - Or, create a custom policy with only the permissions you need.
5. Download the access key ID and secret access key.
6. Configure your AWS CLI with these credentials:

```sh
aws configure
```

---

## AWS Configuration

Configure your AWS credentials using the AWS CLI:

```sh
aws configure
```

You will be prompted for:

- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., `us-east-1`)
- Default output format (e.g., `json`)

---

## Getting the Latest Ubuntu AMI ID

The AMI ID for Ubuntu changes frequently. To get the latest Ubuntu 22.04 LTS AMI ID for your region:

```sh
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" "Name=state,Values=available" \
  --query "Images[*].[ImageId,CreationDate]" \
  --output text | sort -k2 -r | head -n1
```

- Replace the AMI ID in your Terraform script with the value returned above.
- The owner `099720109477` is the official Canonical Ubuntu account.

---

## Generating and Using an SSH Key Pair

To securely access your EC2 instance, you need an SSH key pair. Follow these steps:

### 1. Generate an SSH Key Pair

Run the following command in your terminal (replace `my-ec2-hosted-website` with your preferred key name):

```sh
ssh-keygen -t rsa -b 4096 -f my-ec2-hosted-website
```

- This creates two files:
  - `my-ec2-hosted-website` (private key, keep this safe!)
  - `my-ec2-hosted-website.pub` (public key)

### 2. Upload the Public Key to AWS

Use the AWS CLI to import your public key as a Key Pair:

```sh
aws ec2 import-key-pair --key-name my-ec2-hosted-website --public-key-material fileb://my-ec2-hosted-website.pub
```

- Make sure you are in the directory where `my-ec2-hosted-website.pub` is located, or provide the full path.

### 3. Configure Terraform to Use the Key Pair

Set the `key_name` variable in your Terraform configuration to match the name of your AWS EC2 Key Pair. This variable is defined in `variables.tf`:

```hcl
variable "key_name" {
  description = "Name of the existing EC2 KeyPair to enable SSH access."
  type        = string
}
```

In your `terraform.tfvars` file, add:

```hcl
key_name = "my-ec2-hosted-website"
```

### 4. SSH into Your Instance

After deployment, connect using:

```sh
ssh -i my-ec2-hosted-website ubuntu@<EC2_PUBLIC_IP>
```

- Replace `<EC2_PUBLIC_IP>` with the output from Terraform.

---

## Usage

1. **Clone the repository:**

   ```sh
   git clone https://github.com/yourusername/ec2-hosted-website.git
   cd ec2-hosted-website
   ```

2. **Update variables:**

   - Edit `variables.tf` or `terraform.tfvars` to set your desired values (e.g., instance type, AMI ID, key pair name).

3. **Initialize Terraform:**

   ```sh
   terraform init
   ```

4. **Format and Validate Terraform Code:**

   Format your Terraform files:
   ```sh
   terraform fmt
   ```

   Validate your Terraform configuration:
   ```sh
   terraform validate
   ```

5. **Review the execution plan:**

   ```sh
   terraform plan
   ```

6. **Apply the configuration:**

   ```sh
   terraform apply
   ```

   - Type `yes` when prompted to confirm.

7. **Access your website:**

   - After deployment, Terraform will output the public IP or DNS of your EC2 instance.
   - **Please wait a few minutes before accessing the website** to allow the EC2 instance to finish initializing and Nginx to start.
   - Open your browser and navigate to `http://<EC2_PUBLIC_IP>`.

---

## Project Structure

```
ec2-hosted-website/
├── main.tf           # Main Terraform configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output values (e.g., public IP)
├── README.md         # This file
```

---

## Cleaning Up

To destroy all resources created by Terraform:

```sh
terraform destroy
```

### Deleting the Key Pair

When you're done with the project, you can delete the key pair from AWS:

```sh
aws ec2 delete-key-pair --key-name my-ec2-hosted-website
```

Replace `my-ec2-hosted-website` with the actual name of your key pair.

**Note:** This only deletes the key pair from AWS. Your local private key file will still exist on your machine. If you want to delete that as well, you can run:

```sh
rm my-ec2-hosted-website
rm my-ec2-hosted-website.pub
```

**Important:** Make sure you no longer need SSH access to any EC2 instances before deleting the key pair, as you won't be able to SSH into instances that were launched with this key pair.

---

## Troubleshooting

- **SSH Access:** If you need SSH access, ensure your key pair exists in AWS and your security group allows SSH (port 22).
- **Website Not Loading:** Check the EC2 instance's security group to ensure port 80 is open to 0.0.0.0/0.
- **AMI Not Found:** Double-check the AMI ID for your region and update it in your Terraform files.

---


## Security Note: Restricting Access

**Important:**

- In this example, HTTP (port 80) and SSH (port 22) are allowed from anywhere (`0.0.0.0/0`) for demonstration and testing purposes.
- **This is NOT recommended for production or public-facing deployments.**
- You should restrict access to your own IP address for better security.

### How to Find Your Public IP Address

Run this command in your terminal:

```sh
curl ifconfig.me
```

- Use the result (e.g., `203.0.113.42`) and set your variables as follows:

```hcl
allowed_cidr     = "203.0.113.42/32"  # For HTTP
ssh_allowed_cidr = "203.0.113.42/32"  # For SSH
```

- This will only allow access from your personal IP address.

--- 

## References

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
- [Tooplate Templates](https://www.tooplate.com/) 

---
