# Memcached Deployment with Forgejo CI/CD & Vault

Fully automated, secure Memcached deployment using Forgejo CI/CD with Vault secret management.

## Features

- ✅ **Vault Integration**: All configuration from Vault (auto-creates path if missing)
- ✅ **Secure Docker Build**: Multi-stage build with build-time secret injection
- ✅ **No Environment Variables**: Clean docker-compose.yml without exposed secrets
- ✅ **Forgejo CI/CD**: Fully automated deployment pipeline
- ✅ **Non-root Container**: Runs as UID 11211
- ✅ **Health Checks**: Automated health monitoring

## Repository Structure
```
memcached-deployment/
├── .forgejo/workflows/
│   └── deploy-memcached.yml
├── docker/
│   └── Dockerfile
├── scripts/
│   └── init-vault-secrets.sh
├── docker-compose.yml
└── README.md
```

## Quick Start

### 1. Setup Vault Secrets
```bash
export VAULT_ADDR="https://vault.edusuc.net"
export VAULT_TOKEN="your-vault-token"
./scripts/init-vault-secrets.sh
```

### 2. Configure Forgejo Secrets

Add these secrets in your Forgejo repository:
- `VAULT_ADDR`: https://vault.edusuc.net
- `VAULT_TOKEN`: Your Vault access token
- `GITHUB_TOKEN`: For container registry access

### 3. Deploy
```bash
git add .
git commit -m "Deploy memcached"
git push origin main
```

## Vault Configuration

All configuration stored at: `secret/Dev-secret/memcached`

Values:
- `max_memory`: 128 (MB)
- `max_connections`: 1024
- `port`: 11211
- `threads`: 4
- `max_item_size`: 1m
- `version`: 1.6.23

## Security

- Multi-stage Docker build
- Non-root user execution
- No secrets in environment variables
- All config from Vault
- Resource limits enforced

## Monitoring
```bash
# Check health
docker exec memcached nc -z localhost 11211

# View logs
docker-compose logs -f memcached
```

## Repository

https://github.com/baffwuah77/memcached-deployment
