# IAM Least Privilege - KijaniKiosk

## Use Case
KijaniKiosk EC2 app needs to upload product images to S3.

## Role: kijanikiosk-ec2-role (EC2 assumes it, no keys)

## Policy JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
      "Resource": ["arn:aws:s3:::kijanikiosk-products", "arn:aws:s3:::kijanikiosk-products/*"]
    },
    {
      "Effect": "Allow",
      "Action": ["logs:CreateLogStream", "logs:PutLogEvents"],
      "Resource": "arn:aws:logs:us-east-1:*:log-group:/kijaniosk/*"
    },
    {
      "Effect": "Deny",
      "Action": "s3:DeleteBucket",
      "Resource": "*"
    }
  ]
}

## Why Least Privilege
Only one bucket, only upload/download, only KijaniKiosk logs. If hacked, attacker cannot delete or access other services.