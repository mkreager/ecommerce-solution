require "refile/s3"

aws = {
  access_key_id: ENV["aws_access_key_id"],
  secret_access_key: ENV["aws_secret_access_key"],
  region: "us-east-1",
  bucket: "skphoto.sales",
}
Refile.cache = Refile::S3.new(max_size: 10.megabytes, prefix: "cache", **aws)
Refile.store = Refile::S3.new(prefix: "store/original", **aws)