---
title: Create k3d cluster
---

Firstly set/create some common config:

```bash
export DOCKER_NETWORK="k3d-vault-net" # create a dedicated docker network
docker network create $DOCKER_NETWORK
mkdir -p /tmp/k3d/kubelet/pods

echo "---
apiVersion: k3d.io/v1alpha4
kind: Simple
metadata:
  name: vault-k8s
servers: 1
agents: 2
network: $DOCKER_NETWORK
volumes:
  # needed for the CSI driver
  - volume: /tmp/k3d/kubelet/pods:/var/lib/kubelet/pods:shared" > cluster.yaml
```

Create the cluster:

```bash
k3d cluster create --config cluster.yaml \
  --api-port $(ip route get 8.8.8.8 | awk '{print $7}'):16550
```

Explicitly fetch the kubeconfig to a file to make sure you connect to the right cluster with `kubectl`:

```bash
k3d kubeconfig get vault-k8s > k3d-kubeconfig.yaml
export KUBECONFIG=$PWD/k3d-kubeconfig.yaml

# test the kubeconfig works and cluster is running
kubectl get pods --namespace kube-system
```

You should wait for all the pods in the `kube-system` namespace to be Running/Completed.
