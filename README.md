# FastAPI on ECS Fargate with Terraform

This repository creates FastAPI app on ECS Fargate with Terraform. The FastAPI app is located at private subnets and the traffic is managed by ALB.

![Architecture](/img/architecture.png)

# Required knowledge

- FastAPI
- Terraform
- GitHub Actions
- AWS
- Docker

# Setup

## 1. Setup environment variables

```bash
$ export AWS_PROFILE=xxxxx
$ export AWS_ACCOUNT_ID=xxxxx
```

## 2. Create ECR repository

```bash
$ cd infrastructure/provisioning

$ sh ecr.sh
Enter app name: my-app
```

The ECR repository namely `my-app` will be created.

## 3. Push docker image to ECR

```bash
$ cd api

$ sh local-push-to-ecr.sh
Enter app name: my-app
```

The FastAPI docker image will be pushed to the ECR. Note that you should enter the same app name as ECR repository.

## 4. Create backend for Terraform with CloudFormation

```bash
$ cd infrastructure/provisioning

$ sh backend.sh
Enter unique S3 bucket name for Terraform Backend: my-app-tfstate
Enter dynamodb name for Terraform Backend: my-app-tfstate
Enter Cloudformation stack name for Terraform Backend: my-app-tfstate
```

S3 bucket and DynamoDB will be created. These resource will be used for Terraform backend.

## 4. Create resources with Terraform

Change `bucket` and `dynamodb_table` at `infrastructure/terraform/backend.tf`.

```tf
backend "s3" {
   bucket         = "my-app-tfstate" # This should be the name you defined at step 3.
   key            = "terraform.tfstate"
   dynamodb_table = "my-app-tfstate" # This should be the name you defined at step 3.
   region         = "ap-northeast-1"
}
```

Then,

```bash
$ cd infrastructure/terraform

$ terraform init

$ terraform apply
```

Resources such as VPC, NAT, ECS, ELB will be created.

## 5. Setup GitHub Actions secrets

Assign the following GitHub Actions secrets for continuous delivery of ECS at `.github/workflows/cd_ecs.yml`.

- `AWS_IAM_ROLE_ARN`: ARN of IAM role for GitHub Actions
- `ECR_REPO_NAME`: ECR repo name
- `TASK_DEFINITION_FAMILY_NAME`: ECS task definition name
- `ECS_CLUSTER_NAME`: ECS cluster name
- `ECS_SERVICE_NAME`: ECS service name
