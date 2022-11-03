---
title: External Secrets Operator
---

# TODO

```bash title="eso-install.sh"
helm repo add external-secrets https://charts.external-secrets.io

helm install external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --debug \
    --set installCRDs=true


echo "Waiting for the pods to be Ready.."
kubectl wait --for=condition=Ready pod -l "app.kubernetes.io/instance=external-secrets" -n external-secrets --timeout=60s
kubectl get pods -l "app.kubernetes.io/instance=external-secrets" -n external-secrets
```

## Vault Terraform configuration

```hcl title="vault-eso.tf"
provider "vault" {
  # Configured with environment variables:
  # VAULT_ADDR
  # VAULT_TOKEN
}

resource "vault_policy" "ext-secrets" {
  name = "ext-secrets"

  policy = <<EOT
path "secret/data/foo" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "database" {
  backend                          = "kubernetes" # default path
  role_name                        = "ext-secrets"
  bound_service_account_names      = ["ext-secrets-sa"]
  bound_service_account_namespaces = ["external-secrets"]
  token_ttl                        = 3600
  token_policies                   = ["ext-secrets"]
  # external-secrets operator does something strange with audience, so let it be null:
  #audience                         = "k3s"
}
```

```yaml title="ext-secret-vault.yaml"
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: vault-example
spec:
  refreshInterval: "15s"
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: example-sync
  data:
  - secretKey: foobar
    remoteRef:
      key: secret/foo
      property: my-value
```

```yaml title="secret-store-vault.yaml"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ext-secrets-sa
---
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://dev-vault:8200"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "ext-secrets"
          serviceAccountRef:
            name: "ext-secrets-sa"
```

