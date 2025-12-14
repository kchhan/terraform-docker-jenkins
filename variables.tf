variable "instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "controller"
}

variable "instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "The key pair to ssh the server with"
  type        = string
  default     = "ec2-controller-key"
}