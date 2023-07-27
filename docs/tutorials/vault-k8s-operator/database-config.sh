kubectl exec vault-0 -n vault -- vault secrets enable database
kubectl exec vault-0 -n vault -- vault write database/config/verinotes-postgres \
    plugin_name="postgresql-database-plugin" \
    allowed_roles="verinotes" \
    connection_url="postgresql://{{username}}:{{password}}@postgres-postgresql.verinotes.svc.cluster.local:5432/verinotes" \
    username="postgres" \
    password="veristrongpassword" \
    password_authentication="scram-sha-256"

kubectl exec vault-0 -n vault -- vault write database/roles/verinotes \
    db_name="verinotes-postgres" \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1m" \
    max_ttl="24h"

kubectl cp database-verinotes.hcl -n vault vault-0:/tmp
kubectl exec vault-0 -n vault -- vault policy write verinotes-postgres /tmp/database-verinotes.hcl

kubectl exec vault-0 -n vault -- vault write auth/kubernetes/role/vso-verinotes-dynamic \
   bound_service_account_names=verinotes \
   bound_service_account_namespaces=verinotes \
   policies=verinotes-postgres \
   audience=vault \
   ttl=24h
