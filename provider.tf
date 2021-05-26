provider "aws" {
  region                  = "us-east-1"
  # shared_credentials_file = "~/.aws/credentials"
  # profile                 = "ccsandbox"
}

terraform {
  backend "s3" {
    encrypt                 = false
    bucket                  = "absipatcodepipes"
    dynamodb_table          = "absipatcodepipes"
    region                  = "us-east-1"
    key                     = "codepipes/terra.state"
    # shared_credentials_file = "~/.aws/credentials"
    # profile                 = "ccsandbox"
  }
}
