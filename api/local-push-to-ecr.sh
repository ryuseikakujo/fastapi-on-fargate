#!/bin/bash

read -p "Enter app name: " APP_NAME

ECR_BASE_URI=$AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com

aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $ECR_BASE_URI

docker build -t $ECR_BASE_URI/$APP_NAME:latest --platform amd64 .

docker push $ECR_BASE_URI/$APP_NAME:latest
