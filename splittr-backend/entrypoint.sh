#!/bin/bash

set -e

if [ "$RUN_SCHEMA_MIGRATIONS" = "true" ]; then
  secrets_manager_secrets=("${SECRET_PREFIX}-api")

  for secret in "${secrets_manager_secrets[@]}"; do
    secret_value=$(aws secretsmanager get-secret-value --secret-id $secret --query SecretString --output text --region ${AWS_REGION})

    while IFS="=" read -r key value; do
      export "$key"="$value"
    done < <(echo "$secret_value" | jq -r 'to_entries[] | "\(.key)=\(.value)"')
  done
  
  if [ "$SECRET_PREFIX" = "dev" ]; then
    npm run migrate:dev
  else
    npm run migrate
  fi
fi

node src/index.js