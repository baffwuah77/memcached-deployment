#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Vault configuration
VAULT_ADDR=${VAULT_ADDR:-"https://vault.edusuc.net"}
VAULT_PATH="secret/Dev-secret/memcached"

log_info "Initializing Vault secrets for Memcached..."
log_info "Vault Address: $VAULT_ADDR"
log_info "Vault Path: $VAULT_PATH"

# Check if vault CLI is available
if ! command -v vault &> /dev/null; then
    log_error "Vault CLI not found. Please install it first."
    exit 1
fi

# Check Vault connectivity
if ! vault status &> /dev/null; then
    log_error "Cannot connect to Vault. Check VAULT_ADDR and VAULT_TOKEN"
    exit 1
fi

log_info "✓ Connected to Vault successfully"

# Check if path exists
if vault kv get "$VAULT_PATH" &> /dev/null; then
    log_warn "Vault path already exists: $VAULT_PATH"
    read -p "Do you want to overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Keeping existing secrets"
        exit 0
    fi
fi

# Generate secure values
MEMCACHED_MAX_MEMORY=${MEMCACHED_MAX_MEMORY:-"128"}
MEMCACHED_MAX_CONNECTIONS=${MEMCACHED_MAX_CONNECTIONS:-"1024"}
MEMCACHED_PORT=${MEMCACHED_PORT:-"11211"}
MEMCACHED_THREADS=${MEMCACHED_THREADS:-"4"}
MEMCACHED_MAX_ITEM_SIZE=${MEMCACHED_MAX_ITEM_SIZE:-"1m"}

# Create Vault secrets
log_info "Creating Vault secrets..."

vault kv put "$VAULT_PATH" \
  max_memory="$MEMCACHED_MAX_MEMORY" \
  max_connections="$MEMCACHED_MAX_CONNECTIONS" \
  port="$MEMCACHED_PORT" \
  threads="$MEMCACHED_THREADS" \
  max_item_size="$MEMCACHED_MAX_ITEM_SIZE" \
  version="1.6.23"

log_info "✓ Vault secrets created successfully!"

# Verify
log_info "Verifying secrets..."
vault kv get "$VAULT_PATH"

echo ""
log_info "=== Vault Setup Complete ==="
log_info "Path: $VAULT_PATH"
