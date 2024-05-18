terraform {
  backend "s3" {
    region = "us-west-2"
    key    = "vault-nice-cluster.tfstate"
    bucket = "my-s3-bucket"
  }
}