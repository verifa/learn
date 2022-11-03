---
title: Vault Agent sidecar injector installation
---

Vault sidecar injector can be installed with the official Vault Helm chart. It adds a mutating webhook controller into the cluster that modifies pod definitions adding the sidecar container to your Kubernetes manifests.

## Installing the Helm chart

```bash
# install Vault Helm chart connected to an external Vault
# 'dev-vault' is the name of the container, docker resolves this in the same network
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault \
    --set "injector.externalVaultAddr=http://dev-vault:8200" \
    --set "csi.enabled=true"
```


### Pros and cons

