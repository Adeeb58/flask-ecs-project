variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "app_image" {
  description = "The Docker image for the application from ECR"
  type        = string
  // Replace this with your actual ECR URI
  default     = "public.ecr.aws/g9j0e3q3/flask-app:latest"
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy into"
  type        = string
  // We will find this value in the AWS Console
}

variable "subnet_id" {
  description = "The ID of a public subnet to deploy the task into"
  type        = string
  // We will find this value in the AWS Console
}