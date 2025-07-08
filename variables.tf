variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-2"
}

variable "availability_zone" {
  description = "AWS availability zone to deploy in"
  type        = string
  default     = "us-east-2a"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 24.04."
  type        = string
  default     = "ami-0d1b5a8c13042c939"
}

variable "key_name" {
  description = "Name of the existing EC2 KeyPair to enable SSH access."
  type        = string
  default     = "my-ec2-hosted-website"
}

variable "website_zip_url" {
  description = "URL of the Tooplate website zip file."
  type        = string
  default     = "https://www.tooplate.com/zip-templates/2135_mini_finance.zip"
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access the website (HTTP)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the instance."
  type        = string
  default     = "0.0.0.0/0"
}
