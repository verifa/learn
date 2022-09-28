---
title: Create k3d cluster
---

```bash
# The extra flag maps the localhost:8081 to the loadbalancer container:80
k3d cluster create k8s-101 -p "8081:80@loadbalancer"
k3d kubeconfig get k8s-101 > k3d-kubeconfig.yaml

export KUBECONFIG=$PWD/k3d-kubeconfig.yaml
kubectl get pods --namespace kube-system
```

You should wait for all the pods in the `kube-system` namespace to be Running/Completed, in the rest of the content there's no notion of namespaces anywhere, which means everything will be deployed into the `default` namespace.
This is a very, very, bad practice in production clusters, but it makes our lives bit easier during this tutorial.
