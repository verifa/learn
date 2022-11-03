---
title: Vault Agent sidecar injector demo
---

## Vault Terraform configuration

```hcl title="vault-injector-role.tf"
provider "vault" {
  # Configured with environment variables:
  # VAULT_ADDR
  # VAULT_TOKEN
}

resource "vault_policy" "devweb-app" {
  name = "devwebapp"

  policy = <<EOT
path "secret/data/devwebapp/config" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "devweb-app" {
  backend                          = "kubernetes" # default path
  role_name                        = "devweb-app"
  bound_service_account_names      = ["internal-app"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = ["devwebapp"]
  audience                         = "k3s"
}
```

```yaml title="injector-demo-app.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: devwebapp
  labels:
    app: devwebapp
  annotations:
    vault.hashicorp.com/agent-inject: 'true'
    vault.hashicorp.com/role: 'devweb-app'
    vault.hashicorp.com/agent-inject-secret-credentials.txt: 'secret/data/devwebapp/config'
spec:
  serviceAccountName: internal-app
  containers:
    - name: app
      image: burtlo/devwebapp-ruby:k8s
```

### Pros and cons

