---
title: Vault CSI driver
---


```bash title="csi-install.sh"
#!/bin/bash
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install csi secrets-store-csi-driver/secrets-store-csi-driver --debug

vault kv put secret/db-pass password="db-secret-password"

echo "Waiting for the pods to be Ready.."
kubectl wait --for=condition=Ready pod -l app=secrets-store-csi-driver --timeout=60s
kubectl get pods -l app=secrets-store-csi-driver
```

## Vault Terraform configuration

```hcl title="vault-eso.tf"
provider "vault" {
  # Configured with environment variables:
  # VAULT_ADDR
  # VAULT_TOKEN
}

resource "vault_policy" "internal-app" {
  name = "internal-app"

  policy = <<EOT
path "secret/data/db-pass" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "database" {
  backend                          = "kubernetes" # default path
  role_name                        = "database"
  bound_service_account_names      = ["webapp-sa"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = ["internal-app"]
#  audience                         = "k3s"
}
```

```yaml title="spc-vault.yaml"
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: vault-database
spec:
  provider: vault
  parameters:
    vaultAddress: "http://dev-vault:8200"
    roleName: "database"
    objects: |
      - objectName: "db-password"
        secretPath: "secret/data/db-pass"
        secretKey: "password"
```

```yaml title="csi-demo-app.yaml"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: webapp-sa
---
kind: Pod
apiVersion: v1
metadata:
  name: webapp
  labels:
    app: webapp
spec:
  serviceAccountName: webapp-sa
  containers:
  - image: jweissig/app:0.0.1
    name: webapp
    volumeMounts:
    - name: secrets-store-inline
      mountPath: "/mnt/secrets-store"
      readOnly: true
  volumes:
    - name: secrets-store-inline
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: "vault-database"
```


### Pros and cons

