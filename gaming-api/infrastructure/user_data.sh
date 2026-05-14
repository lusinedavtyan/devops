#!/bin/bash
set -e

DB_USERNAME=$(aws ssm get-parameter \
  --name "/project-genesis/db-username" \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

DB_PASSWORD=$(aws ssm get-parameter \
  --name "/project-genesis/db-password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

docker run -d \
  -p 80:8000 \
  -e DB_USERNAME="$DB_USERNAME" \
  -e DB_PASSWORD="$DB_PASSWORD" \
  your-image-name
