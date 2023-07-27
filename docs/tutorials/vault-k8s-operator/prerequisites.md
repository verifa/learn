---
title: Prequisites
---

## Install

- [docker](https://docs.docker.com/get-docker) (or similar, such as [Rancher desktop](https://docs.rancherdesktop.io/getting-started/installation) or [Podman Desktop](https://podman-desktop.io/docs/Installation))
- [k3d](https://k3d.io/v5.4.6/#installation) or [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) - If you want to run the tutorial locally
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [helm >=3.6](https://helm.sh/docs/intro/install/)

## Create a cluster

We recommend using a local cluster, but you can of course use whatever cluster you have at hand. The tutorial should work on any recent version of Kubernetes and there's nothing special that has to be configured for this tutorial.

### k3d

```bash
k3d cluster create vault-k8s-operator
```

### KinD

```bash
kind create cluster --name vault-k8s-operator
```

### Test cluster

Make sure pods in the `kube-system` namespace are `Running`, this also tests that `kubeconfig`/context is found and correct:

```bash
kubectl get pods -n kube-system
```

Make sure you are seeing pods that are just now created and you are not accessing a production cluster that you were just using 😱

