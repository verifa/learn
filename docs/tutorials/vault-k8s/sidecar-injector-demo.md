---
title: Vault Agent sidecar injector demo
---

## Vault Terraform configuration

Create a new folder to hold the Terraform configuration for this section:

```bash
cd ..
mkdir injector-demo
cd injector-demo
```

Create `main.tf` which holds all the Terraform configuration:

```hcl title="main.tf"
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

Apply the terraform configuration after reviewing the file and the plan:

```bash
terraform init
terraform apply
```

## Sidecar injector

Let's define a Pod manifest that accesses the secret using annotations for the configuration:

```yaml title="sidecar-demo.yaml"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sidecar-app
---
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-app
  labels:
    app: sidecar-app
  annotations:
    vault.hashicorp.com/agent-inject: 'true'
    vault.hashicorp.com/role: 'sidecar'
    vault.hashicorp.com/agent-inject-secret-credentials.txt: 'secret/data/foo'
    vault.hashicorp.com/agent-inject-template-credentials.txt: |
      {{- with secret "secret/data/foo" -}}
      secret-value: {{ .Data.data.key }}
      {{- end }}
spec:
  serviceAccountName: sidecar-app
  containers:
    - name: sidecar-app
      image: nginx
```

After the container is running we can examine the secret written:

```bash
kubectl exec sidecar-app -c sidecar-app -- cat /vault/secrets/credentials.txt
```

