# terraform-aws-s3-replicated
This module will create s3 buckets with cross-region replication set up for you. Versioning is on by default.


## Module Usage
```
module "s3_replicated" {
  source = "github.com/dirt-simple/terraform-aws-s3-replicated"
}

output "source_bucket_arn" {
  value = "${module.s3_replicated.source_bucket_arn}"
}

output "replica_bucket_arn" {
  value = "${module.s3_replicated.replica_bucket_arn}"
}
```

## Argument Reference
The following arguments are supported:

* `source_bucket_name` - (Optional) The name of the source bucket. If not provided one will be generated. The default is s3-replicated-<ACCT_ID>.

* `source_bucket_region` - (Optional) The AWS region that the source bucket will be created in. The default for this attribute is us-east-1.

* `replica_postfix` - (Optional) This will be appended to the replica bucket name. The default is s3-replicated-<ACCT_ID>-replica.

* `replica_bucket_region` - (Optional) The AWS region that the replica bucket will be created in. The default for this attribute is us-west-1.

* `replica_bucket_storage_class` - (Optional) The s2 storage class for replica bucket. The default for this attribute is REDUCED_REDUNDANCY.

* `versioning_enabled` - (Optional) Enable versioning on the buckets. The default is true.

## Attributes Reference
In addition to all arguments above, the following attributes are exported:

* `source_bucket_arn` - The ARN for the created source s3 bucket.

* `replica_bucket_arn` - The ARN for the created replica s3 bucket.

