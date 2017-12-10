require 'aws-sdk'

Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(ENV["aws_access_key_id"], ENV["aws_secret_access_key"])
})

s3 = Aws::S3::Resource.new
Bucket = s3.bucket("skphoto.sales")

AWS_CLIENT = Aws::S3::Client.new