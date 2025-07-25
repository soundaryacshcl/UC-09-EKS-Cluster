terraform {
  backend "s3" {
    bucket       = "us-east-bucket-usecases"
    key          = "usecase9/statefile.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}