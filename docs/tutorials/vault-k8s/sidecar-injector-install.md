---
title: Vault Agent sidecar injector installation
---

Vault sidecar injector can be installed with the official Vault Helm chart. It adds a mutating webhook controller into the cluster that modifies pod definitions adding the sidecar container to your Kubernetes manifests.

## Configuring service entry for Vault

To make sure our pods can resolve the name `dev-vault` to the Vault address let's add a Service and manual Endpoints resources to the cluster:

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: dev-vault
spec:
  ports:
    - name: http
      protocol: TCP
      port: 8200
      targetPort: 8200
---
apiVersion: v1
kind: Endpoints
metadata:
  name: dev-vault
subsets:
- addresses:
  - ip: $(docker inspect dev-vault | jq -r ".[0].NetworkSettings.Networks.\"${DOCKER_NETWORK}\".IPAddress")
  ports:
  - name: http
    port: 8200
    protocol: TCP
EOF
```

!!! note
    Depending on your version of the tools and overall setup, this might not be needed but we've included it to make the tutorial stable.

## Installing the Helm chart
 
Install Vault Helm chart which connects to the external Vault. Note that `dev-vault` is the name we used for the service, and is also the name of the docker container.

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault \
    --set "global.externalVaultAddr=http://dev-vault:8200" \
    --set "csi.enabled=true" \
    --version 0.22.1
```

