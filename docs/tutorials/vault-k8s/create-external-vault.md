---
title: Create an external Vault using Docker
---

A lot of tutorials install Vault inside the Kubernetes cluster using the Helm chart, but doing so skips some of the setup necessary when integrating with an external Vault. To make the tutorial more interesting let's run an external Vault inside a Docker container, it's important to note that the Vault and k3d cluster is running inside the same Docker network, thus the Vault can be reached using the name of the docker container.

```bash
export VAULT_TOKEN="root" # in dev mode we can set the value for root token
VAULT_VERSION="1.12.0"
docker run --cap-add=IPC_LOCK -p 8200:8200 -d --name=dev-vault -e "VAULT_DEV_ROOT_TOKEN_ID=${VAULT_TOKEN}" --network ${DOCKER_NETWORK} vault:${VAULT_VERSION}
export VAULT_ADDR=http://$(docker inspect dev-vault | jq -r ".[0].NetworkSettings.Networks.\"${DOCKER_NETWORK}\".IPAddress"):8200
```

## Test the Vault locally

```bash
vault status
vault token lookup
```

## Add some secrets

```bash
vault kv put secret/foo key=s3cr3t
vault kv put secret/bar password=verisecret
```
