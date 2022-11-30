---
title: Prequisites
---

!!! warning
    Unfortunately this tutorial is tested only on Linux since the CSI driver only works on Linux.
    The tutorial should work on most distributions, as long as k3d supports it.

## Install

- [vault (for CLI)](https://developer.hashicorp.com/vault/docs/install)
- [docker](https://docs.docker.com/get-docker) (or similar, such as [Rancher desktop](https://docs.rancherdesktop.io/getting-started/installation))
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [k3d](https://k3d.io/v5.4.6/#installation)
- [jq](https://stedolan.github.io/jq/download/)
- [terraform](https://www.terraform.io/downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [helm >=3.6](https://helm.sh/docs/intro/install/)

## Test k3d

```bash
k3d cluster create vault-k8s
k3d kubeconfig get vault-k8s > k3d-kubeconfig.yaml
export KUBECONFIG=$PWD/k3d-kubeconfig.yaml
kubectl get namespaces
# cleanup the test cluster and configs
k3d cluster delete vault-k8s
rm k3d-kubeconfig.yaml
unset KUBECONFIG
```
