variable "source_bucket_name" {
  description = "(Optional) The name of the source bucket. If not provided one will be generated. The default is s3-replicated-<ACCT_ID>."
  default = ""
}
variable "source_bucket_region" {
  description = "(Optional) The AWS region that the source bucket will be created in. The default for this attribute is us-east-1."
  default = "us-east-1"
}

variable "replica_postfix" {
  description = "(Optional) This will be appended to the replica bucket name. The default is s3-replicated-<ACCT_ID>-replica."
  default = "-replica"
}

variable "replica_bucket_region" {
  description = "(Optional) The AWS region that the replica bucket will be created in. The default for this attribute is us-west-1."
  default = "us-west-1"
}

variable "replica_bucket_storage_class" {
  description = "(Optional) The s2 storage class for replica bucket. The default for this attribute is REDUCED_REDUNDANCY."
  default = "REDUCED_REDUNDANCY"
}

variable "enable_versioning" {
  description = "(Optional) Enable versioning on the buckets. The default is true."
  default = "true"
}

provider "aws" {
  region = "${var.source_bucket_region}"
}

provider "aws" {
  alias = "replica"
  region = "${var.replica_bucket_region}"
}

data "aws_caller_identity" "acct" {}

locals {
  bucket_name = "${var.source_bucket_name == "" ? "s3-replication-${data.aws_caller_identity.acct.account_id}" : var.source_bucket_name}"
}

data "aws_iam_policy_document" "s3_replication_role" {
  provider = "aws"
  statement {
    actions = [
      "sts:AssumeRole"]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3_replication" {
  name = "s3-replication-role-${local.bucket_name}"
  assume_role_policy = "${data.aws_iam_policy_document.s3_replication_role.json}"
}

data "aws_iam_policy_document" "s3_replication_policy" {
  provider = "aws"
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.source.arn}"]
  }
  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.source.arn}/*"]
  }
  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.replica.arn}/*"]
  }
}

resource "aws_iam_policy" "s3_replication" {
  name = "s3-replication-policy-${local.bucket_name}"
  policy = "${data.aws_iam_policy_document.s3_replication_policy.json}"
}

resource "aws_iam_policy_attachment" "s3_replication" {
  name = "s3-replication-policy-attachment-${local.bucket_name}"
  roles = [
    "${aws_iam_role.s3_replication.name}"]
  policy_arn = "${aws_iam_policy.s3_replication.arn}"
}

resource "aws_s3_bucket" "replica" {
  provider = "aws.replica"
  bucket = "${local.bucket_name}${var.replica_postfix}"
  region = "${var.replica_bucket_region}"
  versioning {
    enabled = "${var.enable_versioning}"
  }
}

resource "aws_s3_bucket" "source" {
  provider = "aws"
  bucket = "${local.bucket_name}"
  region = "${var.source_bucket_region}"
  replication_configuration {
    role = "${aws_iam_role.s3_replication.arn}"
    rules {
      id = "replica"
      prefix = ""
      status = "Enabled"
      destination {
        bucket = "${aws_s3_bucket.replica.arn}"
        storage_class = "${var.replica_bucket_storage_class}"
      }
    }
  }
  versioning {
    enabled = "${var.enable_versioning}"
  }
}

output "source_bucket_arn" {
  value = "${aws_s3_bucket.source.arn}"
}

output "replica_bucket_arn" {
  value = "${aws_s3_bucket.replica.arn}"
}