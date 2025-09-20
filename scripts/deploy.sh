#!/bin/bash
#scripts/deploy.sh
set -e

JSON_FILE=$1
ACCOUNT_ID=$2
ACTION=$3
WORK_DIR=$4

if [[ ! -f "$JSON_FILE" ]]; then
    echo "❌ File $JSON_FILE not found!"
    exit 1
fi

echo "🚀 Executing terraform $ACTION for account $ACCOUNT_ID"

function clean_files() {
  echo "Cleaning files..."
  sleep 3
  rm -f account.auto.tfvars.json
  rm -rf private_key.pem
  rm -rf .terraform
  rm -rf terraform.tfstate
  rm -rf .terraform.lock.hcl
}

cd "$WORK_DIR"

ACCOUNT_JSON=$(jq --arg account_id "$ACCOUNT_ID" '. | .[$account_id]' "$JSON_FILE")

if [[ -z "$ACCOUNT_JSON" ]]; then
    echo "❌ Could not find account with ID '$ACCOUNT_ID' in $JSON_FILE"
    exit 1
fi

export TELEGRAM_BOT_TOKEN=$(echo "$ACCOUNT_JSON" | jq -r '.telegram_bot_token // ""')
export TELEGRAM_CHAT_ID=$(echo "$ACCOUNT_JSON" | jq -r '.telegram_chat_id // ""')
export CF_WARP_CONNECTOR_SECRET=$(echo "$ACCOUNT_JSON" | jq -r '.cf_warp_connector_secret // ""')

echo "📝 Generating terraform variables file..."

echo "$ACCOUNT_JSON" | jq '
  .ssh_key = .ssh_public_key |
  .default_user_ssh_key = .ssh_public_key |
  .shared_volumes_config = (
    [(.block_volumes // [])[] | {key: .display_name | sub("-"; "_"; "g"), value: {display_name, size_in_gbs, device}}]
    | from_entries
  ) |
  .telegram_bot_token = .telegram_bot_token |
  .telegram_chat_id = .telegram_chat_id |
  .cf_warp_connector_secret = .cf_warp_connector_secret |
  
  .nlb_health_check_protocol = .nlb_health_check_protocol |
  .nlb_health_check_path = .nlb_health_check_path |
  .nlb_health_check_return_code = .nlb_health_check_return_code |
  .nlb_health_check_response_regex = .nlb_health_check_response_regex |
  .nlb_health_check_interval = .nlb_health_check_interval |
  .nlb_health_check_timeout = .nlb_health_check_timeout |
  .nlb_health_check_retries = .nlb_health_check_retries |
  
  del(.account_name, .availability_domain, .private_key, .ssh_public_key, .block_volumes, .tf_state_bucket_name, .namespace)
' > account.auto.tfvars.json || clean_files

PRIVATE_KEY=$(echo "$ACCOUNT_JSON" | jq -r ".private_key")
echo "$PRIVATE_KEY" > private_key.pem
chmod 600 private_key.pem

terraform init -reconfigure \
  -backend-config="bucket=$(echo "$ACCOUNT_JSON" | jq -r '.tf_state_bucket_name')" \
  -backend-config="namespace=$(echo "$ACCOUNT_JSON" | jq -r '.namespace')" \
  -backend-config="region=$(echo "$ACCOUNT_JSON" | jq -r '.region')" \
  -backend-config="tenancy_ocid=$(echo "$ACCOUNT_JSON" | jq -r '.tenancy_ocid')" \
  -backend-config="user_ocid=$(echo "$ACCOUNT_JSON" | jq -r '.user_ocid')" \
  -backend-config="fingerprint=$(echo "$ACCOUNT_JSON" | jq -r '.fingerprint')" \
  -backend-config="private_key_path=$(pwd)/private_key.pem" || clean_files

AUTO_APPROVE=""
if [[ "$ACTION" == "apply" || "$ACTION" == "destroy" ]]; then
    AUTO_APPROVE="-auto-approve"
fi

terraform "$ACTION" $AUTO_APPROVE \
    -var="private_key_path=$(pwd)/private_key.pem" \
    -var="telegram_bot_token=${TELEGRAM_BOT_TOKEN}" \
    -var="telegram_chat_id=${TELEGRAM_CHAT_ID}" \
    -var="cf_warp_connector_secret=${CF_WARP_CONNECTOR_SECRET}" || clean_files

echo "✅ Terraform $ACTION completed successfully!"
clean_files