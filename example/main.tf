terraform {
  backend "s3" {
    bucket = "ops-config-mgmt"
    region = "us-east-1"
    key    = "terraform-state/terraform-aws-s3-replicated/terraform.tfstate"
  }
}

module "s3_replicated" {
  source = "github.com/dirt-simple/terraform-aws-s3-replicated"
}

output "source_bucket_arn" {
  value = "${module.s3_replicated.source_bucket_arn}"
}

output "replica_bucket_arn" {
  value = "${module.s3_replicated.replica_bucket_arn}"
}