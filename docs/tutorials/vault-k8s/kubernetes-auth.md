---
title: Kubernetes authentication method
---

In order to verify the service account tokens, the Vault must be configured with a service account. o used in the Vault Kubernetes auth method.

For the record, the service account needs to have the clusterrole `system:auth-delegator`. Here are example commands to create it:

```bash
kubectl create serviceaccount vault
kubectl create clusterrolebinding vault-reviewer-binding 
  --clusterrole=system:auth-delegator 
  --serviceaccount=default:vault
```

Since the sidecar is already installed, the Helm chart also created a service account with the necessary role. We can use the service account instead of creating a new one:

```bash
VAULT_HELM_SECRET_NAME=$(kubectl get secrets --output=json | jq -r '.items[].metadata | select(.name|startswith("vault-token-")).name')

export TF_VAR_token_reviewer_jwt=$(kubectl get secret $VAULT_HELM_SECRET_NAME --output='go-template={{ .data.token }}' | base64 --decode)
export TF_VAR_kubernetes_ca_cert=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}')
export TF_VAR_kubernetes_host=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')
```

## Vault Terraform configuration

```hcl title="main.tf"
provider "vault" {
  # Configured with environment variables:
  # VAULT_ADDR
  # VAULT_TOKEN
}

variable "kubernetes_host" {
  type = string
  description = "URL for the Kubernetes API."
}

variable "kubernetes_ca_cert" {
  type = string
  description = "Base64 encoded CA certificate of the cluster."
}

variable "token_reviewer_jwt" {
  type = string
  description = "JWT token of the Vault Service Account."
}

resource "vault_auth_backend" "this" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "example" {
  backend                = vault_auth_backend.this.path
  kubernetes_host        = var.kubernetes_host
  kubernetes_ca_cert     = base64decode(var.kubernetes_ca_cert)
  token_reviewer_jwt     = var.token_reviewer_jwt
  issuer                 = "api"
  disable_iss_validation = "true" # k8s API checks it
}

resource "vault_kubernetes_auth_backend_role" "default" {
  backend                          = "kubernetes" # default path
  role_name                        = "default"
  bound_service_account_names      = ["default"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = ["default"]
  audience                         = "k3s"
}
```
