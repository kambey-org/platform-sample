output "bucket"   { value = aws_s3_bucket.state.id }
output "role_arn" { value = aws_iam_role.pipeline.arn }
output "role_readonly_arn" { value = aws_iam_role.pull_request.arn }