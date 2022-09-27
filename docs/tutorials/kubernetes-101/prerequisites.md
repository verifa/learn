---
title: Prequisites
---

## Install

- [docker](https://docs.docker.com/get-docker) (or similar, such as [Rancher desktop](https://docs.rancherdesktop.io/getting-started/installation))
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [k3d](https://k3d.io/v5.4.6/#installation)

## Test

```bash
k3d cluster create k8s-101
k3d kubeconfig get k8s-101 > k3d-kubeconfig.yaml
export KUBECONFIG=$PWD/k3d-kubeconfig.yaml
kubectl get namespaces
```
