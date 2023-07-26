---
title: Setup Kubernets Auth Method
---

We are going to be using Kubernetes as the Vault auth method in this tutorial because it's convenient, but note that there are other supported methods too. Check the docs for the ones that are supported right now: <https://developer.hashicorp.com/vault/docs/platform/k8s/vso#features>

## Enable the Auth Method

The Helm Chart installation has already done some pre-requisite work for us, like creating a ServiceAccount behind the scenes. We only have to enable the method as Vault is already able to validate the authentication request at this point.

Open interactive shell in the Vault server container:

```bash
kubectl exec -it vault-0 -n vault -- /bin/sh
```

Run fun Vault CLI commands to enable the Kubernetes auth:

```bash
vault auth enable kubernetes
vault write auth/kubernetes/config \
	kubernetes_host="https://kubernetes.default.svc.cluster.local"
```

You can leave the interactive shell open and move to the next part where we were configure few more things in Vault.
