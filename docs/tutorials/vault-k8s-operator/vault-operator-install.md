---
title: Install Vault Secrets Operator
---

## Installation with Helm

Since we already have the HashiCorp Helm repository available, we can simply run the Helm command to install the chart:

```bash title="install-vso.sh"
--8<-- "tutorials/vault-k8s-operator/install-vso.sh"
```

The Chart has some templating that we could take advantage of to configure the connection and auth details for the Operator while deploying the Helm Chart, but for enhanced learning experience let's do that from scratch by applying some Custom Resources (CRs) next.

### Connection to Vault

We will create a `VaultConnection` CR that basically is just the address of the Vault server:

```yaml title="vault-connection.yaml"
--8<-- "tutorials/vault-k8s-operator/vault-connection.yaml"
```

### Auth to Vault

Next we will create two `VaultAuth` CRs which are application specific resources:

```yaml title="vault-auth.yaml"
--8<-- "tutorials/vault-k8s-operator/vault-auth.yaml"
```

One of these we use with static secrets and one with dynamic secrets.

Now we are all set to consume some secrets!
