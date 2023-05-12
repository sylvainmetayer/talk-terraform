variable "region" {
  description = "AWS region where ressources are deployed"
  type        = string
  default     = "eu-west-1"
}

variable "app" {
  description = "Application prefix"
}

variable "instance_type" {
  description = "EC2 instance type"
}

variable "public_key" {
  description = "SSH public key to allow connection from EC2 instance"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags that will be applied to each resources"
  type        = map(string)
  default = {
    "iac" : "terraform",
  }
}
