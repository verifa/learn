---
title: Kubernetes authentication method
---

Kubernetes service account token are used by Kubernetes workloads to authenticate with Vault, in order for Vault to verify the service account tokens Vault must also be able to authenticate with the Kubernetes API server.

??? tip "tip: How to create the service account manually (not needed for the tutorial)"
    The service account needs to have the clusterrole `system:auth-delegator`. Here are example commands to create it:
    
    ```bash
    kubectl create serviceaccount vault
    kubectl create clusterrolebinding vault-reviewer-binding 
      --clusterrole=system:auth-delegator 
      --serviceaccount=default:vault
    ```
    Make sure to use a long-lived token of this service account instead of a short lived one, example is shown below. Refer to [Kubernetes documentation for the details](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-a-long-lived-api-token-for-a-serviceaccount)

As part of the sidecar injector installation, the Helm chart also created a service account with the necessary role. We can use the service account instead of creating a new one:

```bash
# create long lived token for the service account
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: vault-token
  annotations:
    kubernetes.io/service-account.name: vault
type: kubernetes.io/service-account-token
EOF

export TF_VAR_token_reviewer_jwt=$(kubectl get secret vault-token --output='go-template={{ .data.token }}' | base64 --decode)
export TF_VAR_kubernetes_ca_cert=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}')
export TF_VAR_kubernetes_host=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')
```

## Vault Terraform configuration

Create a new folder to hold the Terraform configuration for this section:

```bash
mkdir k8s-auth
cd k8s-auth
```

Create `main.tf` which holds all the Terraform configuration:

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

resource "vault_kubernetes_auth_backend_config" "this" {
  backend                = vault_auth_backend.this.path
  kubernetes_host        = var.kubernetes_host
  kubernetes_ca_cert     = base64decode(var.kubernetes_ca_cert)
  token_reviewer_jwt     = var.token_reviewer_jwt
  issuer                 = "api"
  disable_iss_validation = "true" # k8s API checks it
}

resource "vault_kubernetes_auth_backend_role" "default" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "default"
  bound_service_account_names      = ["default"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = ["default"]
  audience                         = "k3s"
}
```

Apply the terraform configuration after reviewing the file and the plan:

```bash
terraform init
terraform apply
```

## Test the Kubernetes auth

In order to test the authentication method we can create a pod that uses the default service account (role for it configured above as part of the auth method):

```yaml title="login-app.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: login-app
  labels:
    app: login-app
spec:
  # when not provided 'default' service account will be used
  #serviceAccountName: login-app
  containers:
    - name: app
      image: hashicorp/vault:1.10.0
      env:
        - name: VAULT_ADDR
          value: "http://dev-vault:8200"
      command: ["/bin/sh", "-c"]
      args:
        - |
          TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
          echo "vault write auth/kubernetes/login role=default jwt=$TOKEN" > /tmp/script/run.sh
          sh /tmp/script/run.sh && sleep 600
      volumeMounts:
        - mountPath: /tmp/script
          name: script
  volumes:
    - name: script
      emptyDir:
        medium: Memory
```

When the pod launches it will use the mounted service account token to authenticate against Vault. You can verify the authentication is working by examining the logs after the pod has authenticated: 


```bash
kubectl logs login-app 
```

Here's an example output from a successful authentication:

```bash
Key                                       Value
---                                       -----
token                                     hvs.CAESIBo4XzzMrUP3VfRfug5m9SrqdAtHXh9azKBt94Aw-Tp1Gh4KHGh2cy55czU1VUZwVUp5R25Sd2RnbWZhZmxmRmI
token_accessor                            wQoJ359SrX8RwRxg0VqyjATS
token_duration                            1h
token_renewable                           true
token_policies                            ["default"]
identity_policies                         []
policies                                  ["default"]
token_meta_service_account_name           default
token_meta_service_account_namespace      default
token_meta_service_account_secret_name    n/a
token_meta_service_account_uid            c4636638-7d29-471c-a88d-33f167937b2d
token_meta_role                           default
```

The Vault token can be used to fetch secrets from Vault, but this token is only associated with the `default` policy in Vault which does not grant access to any secrets. In the next sections we will take a look at accessing actual secrets.
