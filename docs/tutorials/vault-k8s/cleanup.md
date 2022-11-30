

```bash
docker network rm $DOCKER_NETWORK
docker rm --force dev-vault
k3d cluster delete vault-k8s
rm -rf /tmp/k3d
rm k3d-kubeconfig.yaml
unset KUBECONFIG
```
