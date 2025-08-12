#!/bin/bash
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
echo "📁 Working directory: $WORK_DIR"

# Function to extract values from JSON
get_value() {
    jq -r ".\"$ACCOUNT_ID\".\"$1\"" "$JSON_FILE" 2>/dev/null || echo ""
}

# Function to mask sensitive data
mask_sensitive_data() {
    local value="$1"
    local visible_chars="${2:-8}"
    
    if [[ ${#value} -gt $((visible_chars * 2)) ]]; then
        echo "${value:0:$visible_chars}...${value: -$visible_chars}"
    else
        echo "***"
    fi
}

# Check if account exists
if ! jq -e ".\"$ACCOUNT_ID\"" "$JSON_FILE" >/dev/null 2>&1; then
    echo "❌ Account $ACCOUNT_ID not found in JSON!"
    exit 1
fi

# DEBUG: Show available keys for this account
echo "🔍 Debug: Available keys for account $ACCOUNT_ID:"
jq ".\"$ACCOUNT_ID\" | keys" "$JSON_FILE"

# Navigate to correct directory
cd "$WORK_DIR"

# Check if we're in the right place
if [[ ! -f "main.tf" ]]; then
    echo "❌ main.tf not found in $WORK_DIR!"
    exit 1
fi

# Try different private key field names
PRIVATE_KEY=""
if [[ -n "$(get_value "private_key")" && "$(get_value "private_key")" != "null" ]]; then
    PRIVATE_KEY=$(get_value "private_key")
    echo "🔑 Using private_key field"
elif [[ -n "$(get_value "private_key_base64")" && "$(get_value "private_key_base64")" != "null" ]]; then
    PRIVATE_KEY_B64=$(get_value "private_key_base64")
    PRIVATE_KEY=$(echo "$PRIVATE_KEY_B64" | base64 -d)
    echo "🔑 Using private_key_base64 field (decoded)"
else
    echo "❌ No private key found!"
    echo "🔍 Available fields:"
    jq ".\"$ACCOUNT_ID\" | keys" "$JSON_FILE"
    exit 1
fi

# Validate private key format
if [[ ! "$PRIVATE_KEY" =~ "BEGIN" ]]; then
    echo "❌ Private key doesn't appear to be in valid format!"
    echo "🔍 First 50 chars: ${PRIVATE_KEY:0:50}..."
    exit 1
fi

echo "$PRIVATE_KEY" > private_key.pem
chmod 600 private_key.pem
echo "✅ Private key created"

# Continue with terraform logic
account_name=$(get_value "account_name")
echo "🔧 Account: $ACCOUNT_ID (***)"

# Show configuration preview with masked sensitive data
echo "🔍 Configuration preview:"
echo "  Region: $(get_value region)"
echo "  Prefix: $(get_value prefix)"
echo "  SSH Key: $(mask_sensitive_data "$(get_value ssh_public_key)" 12)"
echo "  Instance Count: $(get_value instance_count)"
echo "  Instance Shape: $(get_value instance_shape)"
echo "  Memory (GB): $(get_value instance_memory_gb)"
echo "  vCPUs: $(get_value instance_ocpus)"

# Determine if auto-approve should be used based on environment
AUTO_APPROVE=""
if [[ "$GITHUB_ACTIONS" == "true" ]]; then
    AUTO_APPROVE="-auto-approve"
    echo "🤖 GitHub Actions detected - using auto-approve"
else
    echo "💻 Local execution detected - manual confirmation will be requested"
fi

# Terraform execution with conditional approval
case $ACTION in
    "plan")
        echo "📦 Initializing Terraform..."
        terraform init \
            -backend-config="bucket=$(get_value tf_state_bucket_name)" \
            -backend-config="namespace=$(get_value namespace)" \
            -backend-config="key=terraform.tfstate" \
            -backend-config="region=$(get_value region)" \
            -backend-config="tenancy_ocid=$(get_value tenancy_ocid)" \
            -backend-config="user_ocid=$(get_value user_ocid)" \
            -backend-config="fingerprint=$(get_value fingerprint)" \
            -backend-config="private_key_path=$(pwd)/private_key.pem"
        
        echo "📋 Executing terraform $ACTION..."
        terraform $ACTION \
            -var="region=$(get_value region)" \
            -var="compartment_ocid=$(get_value compartment_ocid)" \
            -var="availability_domain=$(get_value availability_domain)" \
            -var="prefix=$(get_value prefix)" \
            -var="ssh_key=$(get_value ssh_public_key)" \
            -var="vcn_cidr=$(get_value vcn_cidr)" \
            -var="subnet_cidr=$(get_value subnet_cidr)" \
            -var="image_ocid=$(get_value image_ocid)" \
            -var="tenancy_ocid=$(get_value tenancy_ocid)" \
            -var="user_ocid=$(get_value user_ocid)" \
            -var="fingerprint=$(get_value fingerprint)" \
            -var="private_key_path=$(pwd)/private_key.pem" \
            -var="instance_count=$(get_value instance_count)" \
            -var="instance_shape=$(get_value instance_shape)" \
            -var="instance_memory_gb=$(get_value instance_memory_gb)" \
            -var="instance_ocpus=$(get_value instance_ocpus)"
        ;;
    "apply"|"destroy")
        echo "📦 Initializing Terraform..."
        terraform init \
            -backend-config="bucket=$(get_value tf_state_bucket_name)" \
            -backend-config="namespace=$(get_value namespace)" \
            -backend-config="key=terraform.tfstate" \
            -backend-config="region=$(get_value region)" \
            -backend-config="tenancy_ocid=$(get_value tenancy_ocid)" \
            -backend-config="user_ocid=$(get_value user_ocid)" \
            -backend-config="fingerprint=$(get_value fingerprint)" \
            -backend-config="private_key_path=$(pwd)/private_key.pem"
        
        # APPLY AUTO-APPROVE ONLY IN GITHUB ACTIONS
        echo "📋 Executing terraform $ACTION..."
        terraform $ACTION $AUTO_APPROVE \
            -var="region=$(get_value region)" \
            -var="compartment_ocid=$(get_value compartment_ocid)" \
            -var="availability_domain=$(get_value availability_domain)" \
            -var="prefix=$(get_value prefix)" \
            -var="ssh_key=$(get_value ssh_public_key)" \
            -var="vcn_cidr=$(get_value vcn_cidr)" \
            -var="subnet_cidr=$(get_value subnet_cidr)" \
            -var="image_ocid=$(get_value image_ocid)" \
            -var="tenancy_ocid=$(get_value tenancy_ocid)" \
            -var="user_ocid=$(get_value user_ocid)" \
            -var="fingerprint=$(get_value fingerprint)" \
            -var="private_key_path=$(pwd)/private_key.pem" \
            -var="instance_count=$(get_value instance_count)" \
            -var="instance_shape=$(get_value instance_shape)" \
            -var="instance_memory_gb=$(get_value instance_memory_gb)" \
            -var="instance_ocpus=$(get_value instance_ocpus)"
        ;;
    *)
        echo "❌ Invalid action: $ACTION"
        echo "Available actions: plan, apply, destroy"
        exit 1
        ;;
esac

echo "✅ Terraform $ACTION completed successfully!"
