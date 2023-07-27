kubectl exec vault-0 -n vault -- vault auth enable kubernetes
kubectl exec vault-0 -n vault -- vault write auth/kubernetes/config kubernetes_host="https://kubernetes.default.svc.cluster.local"
