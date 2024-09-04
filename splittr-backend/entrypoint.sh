#!/bin/bash

set -e

echo "RUN_SCHEMA_MIGRATION is set to $RUN_SCHEMA_MIGRATION"

npm run generate

secrets_manager_secrets=("${SECRET_PREFIX}-api")

for secret in "${secrets_manager_secrets[@]}"; do
  secret_value=$(aws secretsmanager get-secret-value --secret-id $secret --query SecretString --output text --region ${AWS_REGION})

  while IFS="=" read -r key value; do
    export "$key"="$value"
  done < <(echo "$secret_value" | jq -r 'to_entries[] | "\(.key)=\(.value)"')
done

if [ "$RUN_SCHEMA_MIGRATION" = "true" ]; then
  echo "Running schema migrations"
  npm run migrate:deploy
else
  echo "Skipping schema migrations"
fi

node src/app.js
