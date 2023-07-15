variable "aws_account_id" {
  default = "123456789012"
}

variable "app_name" {
  type    = string
  default = "my-app"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "public_subnet_cidrs" {
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "github_org" {
  default = "my-org"
}

variable "github_repo" {
  default = "my-repo"
}
