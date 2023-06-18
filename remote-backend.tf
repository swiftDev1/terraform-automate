resource "aws_s3_bucket" "remote-backend-bucket" {
    bucket = "saucecode-terraform-remote-state-backend-bucket"

    tags = {
        Name = "Remote Terraform State Store"
    }
}

resource "aws_s3_bucket_versioning" "s3-backend-versioning" {
    bucket = aws_s3_bucket.remote-backend-bucket.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-backend-encryption" {
  bucket = aws_s3_bucket.remote-backend-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform-state-lock" {
    name           = "terraform_state"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    tags = {
        "Name" = "DynamoDB Terraform State Lock Table"
    }
}