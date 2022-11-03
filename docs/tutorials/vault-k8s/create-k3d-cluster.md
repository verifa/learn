---
title: Create k3d cluster
---

```bash
DOCKER_NETWORK="k3d-vault-net" # create a dedicated docker network
docker network create $DOCKER_NETWORK

echo "---
apiVersion: k3d.io/v1alpha4
kind: Simple
metadata:
  name: workshop
servers: 1
agents: 2
network: k3d-vault-net # network with Vault already running
volumes:
  # needed for the CSI driver
  - volume: /tmp/k3d/kubelet/pods:/var/lib/kubelet/pods:shared" > cluster.yaml

k3d cluster create --config cluster.yaml --api-port $(ip route get 8.8.8.8 | awk '{print $7}'):16550
k3d kubeconfig get k8s-101 > k3d-kubeconfig.yaml
export KUBECONFIG=$PWD/k3d-kubeconfig.yaml

# test the kubeconfig works and cluster is running
kubectl get pods --namespace kube-system
```

You should wait for all the pods in the `kube-system` namespace to be Running/Completed.
