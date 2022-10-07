---
title: Prequisites
---

## Install

- [docker](https://docs.docker.com/get-docker) (or similar, such as [Rancher desktop](https://docs.rancherdesktop.io/getting-started/installation))
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [k3d](https://k3d.io/v5.4.6/#installation) or [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

## Test

### Test docker works

```bash
docker version
docker ps
```

### Test kubectl works

```bash
kubectl version
```

### Test k3d or kind works

```bash
k3d version
k3d cluster list
```
OR
```bash
kind version
kind get cluster
```

## Setup the environment with k3d or kind

```bash
k3d cluster create k8s-101
k3d kubeconfig get k8s-101 > k3d-kubeconfig.yaml
export KUBECONFIG=$PWD/k3d-kubeconfig.yaml
kubectl get namespaces
k3d cluster delete k8s-101
```
OR
```bash
kind create cluster --name k8s-101
kind get kubeconfig --name k8s-101 > k3d-kubeconfig.yaml
export KUBECONFIG=$PWD/k3d-kubeconfig.yaml
kubectl get namespaces
```
