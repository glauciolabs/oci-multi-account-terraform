#!/bin/bash
set -e

JSON_FILE=$1
ACCOUNT_ID=$2
ACTION=$3
WORK_DIR=$4

if [[ ! -f "$JSON_FILE" ]]; then
    echo "❌ Arquivo $JSON_FILE não encontrado!"
    exit 1
fi

echo "🚀 Executando terraform $ACTION para conta $ACCOUNT_ID"
echo "📁 Diretório de trabalho: $WORK_DIR"

# Função para extrair valores do JSON
get_value() {
    jq -r ".\"$ACCOUNT_ID\".\"$1\"" "$JSON_FILE" 2>/dev/null || echo ""
}

# Verificar se a conta existe
if ! jq -e ".\"$ACCOUNT_ID\"" "$JSON_FILE" >/dev/null 2>&1; then
    echo "❌ Conta $ACCOUNT_ID não encontrada no JSON!"
    exit 1
fi

# DEBUG: Show available keys for this account
echo "🔍 Debug: Available keys for account $ACCOUNT_ID:"
jq ".\"$ACCOUNT_ID\" | keys" "$JSON_FILE"

# Navegar para o diretório correto
cd "$WORK_DIR"

# Verificar se estamos no lugar certo
if [[ ! -f "main.tf" ]]; then
    echo "❌ main.tf não encontrado em $WORK_DIR!"
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
    echo "❌ Nenhuma chave privada encontrada!"
    echo "🔍 Campos disponíveis:"
    jq ".\"$ACCOUNT_ID\" | keys" "$JSON_FILE"
    exit 1
fi

# Validate private key format
if [[ ! "$PRIVATE_KEY" =~ "BEGIN" ]]; then
    echo "❌ Chave privada não parece estar em formato válido!"
    echo "🔍 Primeiros 50 chars: ${PRIVATE_KEY:0:50}..."
    exit 1
fi

echo "$PRIVATE_KEY" > private_key.pem
chmod 600 private_key.pem
echo "✅ Chave privada criada"

# Continue with the rest of your terraform logic...
account_name=$(get_value "account_name")
echo "🔧 Conta: $ACCOUNT_ID ($account_name)"

# Terraform execution
# Terraform execution - FIXED for native OCI backend
case $ACTION in
    "plan"|"apply"|"destroy")
        echo "📦 Inicializando Terraform..."
        terraform init \
            -backend-config="bucket=$(get_value tf_state_bucket_name)" \
            -backend-config="namespace=$(get_value namespace)" \
            -backend-config="key=terraform.tfstate" \
            -backend-config="region=$(get_value region)" \
            -backend-config="tenancy_ocid=$(get_value tenancy_ocid)" \
            -backend-config="user_ocid=$(get_value user_ocid)" \
            -backend-config="fingerprint=$(get_value fingerprint)" \
            -backend-config="private_key_path=$(pwd)/private_key.pem"
        
        echo "📋 Executando terraform $ACTION..."
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
            -var="private_key_path=$(pwd)/private_key.pem"
        ;;
esac


echo "✅ Terraform $ACTION concluído!"
