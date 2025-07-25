terraform {
  backend "s3" {
    bucket       = "terraform-usecases-hcl-us-east"
    key          = "usecase9/statefile.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}