terraform {
  backend "s3" {
    bucket = "clo835-assignment2-dev-s3-bucket"    // Bucket where to SAVE Terraform State
    key    = "terraform.tfstate"                   // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                           // Region where bucket is created
  }
}