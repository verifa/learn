---
title: Demo Application
---

We are going to use the magnificent VeriNotes application to test the dynamic secrets when it connects to the Postgres database, but before that let's take a look at the static secrets by just inspecting if we can create a Kubernetes Secret with the values from Vault.

## Static Secrets

You guessed it, more YAML! Let's create now the resource that will actually reference something in Vault `VaultStaticSecret`:

```yaml title="static-secret.yaml"
--8<-- "tutorials/vault-k8s-operator/static-secret.yaml"
```

## Dynamic Secrets

```yaml title="dynamic-secret.yaml"
--8<-- "tutorials/vault-k8s-operator/dynamic-secret.yaml"
```
