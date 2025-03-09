# Default tags
variable "default_tags" {
  default = {
    "Owner"   = "Jiyun"
    "App"     = "Emp"
    "Project" = "CLO835"
  }
  type        = map(string)
  description = "Default tags for resources"
}

# Prefix to identify resources
variable "prefix" {
  default = "assignment2"
  type        = string
  description = "Prefix to identify resources"
}


# Instance type
variable "instance_type" {
  default = {
    "prod"    = "t3.medium"
    "staging" = "t3.micro"
    "dev"     = "t3.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}

# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}
