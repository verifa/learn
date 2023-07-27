If you're using `KinD` or `k3d`, it's easiest to just delete the cluster:

```bash
k3d cluster delete vault-k8s-operator
#or
kind delete cluster --name vault-k8s-operator
```

If you don't want to delete the whole cluster for some reason, then the next best thing is to cleanup the namespaces:

```bash
kubectl delete namespace verinotes
kubectl delete namespace vso-system
kubectl delete namespace vault
```

