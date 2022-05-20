#AWS provider file

terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 4.13"
   }
 }
}

provider "aws" {
    region = "${var.AWS_REGION}"
}