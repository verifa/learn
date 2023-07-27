kubectl exec vault-0 -n vault -- vault secrets enable -path=kvv2 kv-v2

kubectl cp full-access.hcl -n vault vault-0:/tmp
kubectl exec vault-0 -n vault -- vault policy write full-access /tmp/full-access.hcl

kubectl exec vault-0 -n vault -- vault write auth/kubernetes/role/vso-verinotes-static \
   bound_service_account_names=verinotes \
   bound_service_account_namespaces=verinotes \
   policies=full-access \
   audience=vault \
   ttl=24h

kubectl exec vault-0 -n vault -- vault kv put kvv2/verinotes/config username="static-user" password="static-password"

