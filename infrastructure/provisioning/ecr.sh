#!/bin/bash

# Read variables
read -p "Enter app name: " APP_NAME

# Create ECR repo
aws ecr create-repository \
  --repository-name ${APP_NAME} \
  --image-tag-mutability MUTABLE \
  --encryption-configuration encryptionType=AES256

# Change scanning policy
aws ecr put-image-scanning-configuration \
  --repository-name ${APP_NAME} \
  --image-scanning-configuration scanOnPush=false

# Apply lifecycle policy
aws ecr put-lifecycle-policy \
  --repository-name ${APP_NAME} \
  --lifecycle-policy-text '{
    "rules": [
      {
        "rulePriority": 1,
        "description": "Leaving the latest 5 images",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 5
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }'
