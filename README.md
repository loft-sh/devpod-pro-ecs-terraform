# Deploy DevPod Pro on ECS Fargate

Create a new `terraform.tfvars` with:
```
# The AWS region you want to use
aws_region = "eu-central-1"
# The domain DevPod Pro should be available on
domain = "devpod.example.com"
# The hosted Zone ID the domain is hosted under
hosted_zone_id = "Z..."
```

Then do:
```
terraform init
terraform plan
terraform apply
```

Then go to `https://devpod.example.com` and login with the user `admin` and the password obtained via:
```
terraform output -raw loft_admin_password
```

