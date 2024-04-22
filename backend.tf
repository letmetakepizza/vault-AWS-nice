terraform {
  backend "s3" {
    region = "us-west-2"
    key    = "vault-nice-cluster.tfstate"
    bucket = "your-bucket-name"
  }
}