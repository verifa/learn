---
title: Installing Vault on Kubernetes
---

## Installing Vault Helm Chart

Create a `vault-values.yaml` file for Helm Values to be passed to the installation:

```yaml title="vault-values.yaml"
--8<-- "tutorials/vault-k8s-operator/vault-values.yaml"
```

Install the Helm chart from the HashiCrop Helm repository:

```bash title="install-vault.sh"
--8<-- "tutorials/vault-k8s-operator/install-vault.sh"
```

