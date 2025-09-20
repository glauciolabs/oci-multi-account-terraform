#!/bin/bash
# scripts/validate-local.sh
set -e

echo "🔍 Starting local Terraform validation..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log() {
    local level=$1
    local message=$2
    case $level in
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
    esac
}

# 1. Setup TFLint
log "INFO" "Checking TFLint installation..."
if ! command -v tflint &> /dev/null; then
    log "ERROR" "TFLint not found! Install it first:"
    echo "curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"
    exit 1
fi

log "SUCCESS" "TFLint found: $(tflint --version | head -1)"

# 2. Initialize TFLint plugins
log "INFO" "Initializing TFLint plugins..."
tflint --init

# 3. Run TFLint
log "INFO" "Running TFLint recursive scan..."
if tflint --recursive --format compact; then
    log "SUCCESS" "TFLint passed with no issues!"
else
    log "WARNING" "TFLint found issues (see above)"
    
    # Show detailed JSON report
    echo ""
    log "INFO" "Generating detailed report..."
    tflint --recursive --format json > tflint-results.json 2>/dev/null || true
    
    if [ -f tflint-results.json ]; then
        ISSUES=$(jq '.issues | length' tflint-results.json 2>/dev/null || echo "0")
        log "INFO" "Total issues found: $ISSUES"
        
        if [ "$ISSUES" -gt 0 ]; then
            echo ""
            log "WARNING" "Please fix the issues above before committing!"
        fi
    fi
fi

# 4. Terraform Format Check
echo ""
log "INFO" "Checking Terraform formatting..."
if terraform fmt -check -recursive; then
    log "SUCCESS" "All Terraform files are properly formatted!"
else
    log "ERROR" "Terraform files are not formatted correctly!"
    echo ""
    log "INFO" "Run this command to auto-fix formatting:"
    echo "terraform fmt -recursive"
    echo ""
    read -p "Do you want me to fix formatting now? (y/n): " fix_format
    if [[ $fix_format =~ ^[Yy]$ ]]; then
        terraform fmt -recursive
        log "SUCCESS" "Formatting fixed!"
    else
        log "WARNING" "Please fix formatting before committing"
    fi
fi

# 5. Terraform Validate
echo ""
log "INFO" "Validating Terraform configurations..."

validate_dir() {
    local dir=$1
    if [ -f "$dir/main.tf" ] || [ -f "$dir/variables.tf" ]; then
        log "INFO" "Validating: $dir"
        cd "$dir"
        if terraform init -backend=false -input=false > /dev/null 2>&1; then
            if terraform validate; then
                log "SUCCESS" "✓ $dir is valid"
            else
                log "ERROR" "✗ $dir has validation errors"
                return 1
            fi
        else
            log "ERROR" "✗ Failed to initialize $dir"
            return 1
        fi
        cd - > /dev/null
    fi
}

validation_failed=0

# Validate accounts directory
if ! validate_dir "accounts"; then
    validation_failed=1
fi

# Validate all modules
for dir in modules/*/; do
    if ! validate_dir "$dir"; then
        validation_failed=1
    fi
done

# Final result
echo ""
echo "=========================================="
if [ $validation_failed -eq 0 ]; then
    log "SUCCESS" "All validations passed! Ready to commit 🚀"
    echo ""
    log "INFO" "Next steps:"
    echo "  1. git add ."
    echo "  2. git commit -m 'your message'"
    echo "  3. git push"
else
    log "ERROR" "Some validations failed! Please fix before committing"
    exit 1
fi

# Cleanup
rm -f tflint-results.json
