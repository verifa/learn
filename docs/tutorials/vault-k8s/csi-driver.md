---
title: Vault CSI driver
---

```bash
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo update
helm install csi secrets-store-csi-driver/secrets-store-csi-driver --debug --version 1.2.4

echo "Waiting for the pods to be Ready.."
kubectl wait --for=condition=Ready pod -l app=secrets-store-csi-driver --timeout=60s
kubectl get pods -l app=secrets-store-csi-driver
```

## Vault Terraform configuration

Create a new folder to hold the Terraform configuration for this section:

```bash
cd ..
mkdir csi-demo
cd csi-demo
```

Create main.tf which holds all the Terraform configuration:

```hcl title="main.tf"
provider "vault" {
  # Configured with environment variables:
  # VAULT_ADDR
  # VAULT_TOKEN
}

resource "vault_policy" "csi-app" {
  name = "csi-app"

  policy = <<EOT
path "secret/data/bar" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "csi-app" {
  backend                          = "kubernetes" # default path
  role_name                        = "csi-app"
  bound_service_account_names      = ["csi-app"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = ["csi-app"]
  audience                         = "k3s"
}
```

Apply the terraform configuration after reviewing the file and the plan:

```bash
terraform init
terraform apply
```

## Configuring SecretProviderClass

```yaml title="spc-vault.yaml"
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: vault-csi-app
spec:
  provider: vault
  parameters:
    vaultAddress: "http://dev-vault:8200"
    roleName: "csi-app"
    objects: |
      - objectName: "bar-password"
        secretPath: "secret/data/bar"
        secretKey: "password"
```

## CSI Demo Application

```yaml title="csi-demo-app.yaml"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: csi-app
---
kind: Pod
apiVersion: v1
metadata:
  name: csi-app
  labels:
    app: csi-app
spec:
  serviceAccountName: csi-app
  containers:
  - image: nginx
    name: csi-app
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
          secretProviderClass: "vault-csi-app"
```

After the container is running we can examine the secret written:

```bash
kubectl exec csi-app -- cat /mnt/secrets-store/bar-password && echo
```

