---
title: Dynamic Database Secrets
---

Now let's deploy a PostgreSQL in `verinotes` namespace, we won't create the `verinotes` application quite yet because we need to bootstrap our dynamic secret engine first between Vault and the Postgres database.

## Deploying Postgres

Create a file called `postgres.yaml` with the below contents:

??? tip "Please expand this block, it's a bit long so we wrapped it into an admonition"

    ```yaml title="postgres.yaml" hl_lines="11"
    --8<-- "tutorials/vault-k8s-operator/postgres.yaml"
    ```

You might have noticed the highlighted line, there we are setting a static password for the `postgres` user. This is needed so we can bootstrap the secrets engine later, in production environment we can have Vault rotate the password after bootstrapping for additional security.

## Configuring Database Secrets Engine

Let's enable the database secrets engine and configure it with details to connect to the newly create Postgres instance, note the static password used during installation is now used when bootstrapping the secret engine. This user is needed by Vault to create the dynamic users that the application will use when connecting. Again attach to the Vault server to run the commands, here's the attach command first as a reminder:

```bash
kubectl exec -it vault-0 -n vault -- /bin/sh
```

And then the configuration:

```bash
vault secrets enable database
vault write database/config/verinotes-postgres \
    plugin_name="postgresql-database-plugin" \
    allowed_roles="verinotes" \
    connection_url="postgresql://{{username}}:{{password}}@postgres-postgresql.verinotes.svc.cluster.local:5432/verinotes" \
    username="postgres" \
    password="veristrongpassword" \
    password_authentication="scram-sha-256"
```

Now we are going to create a role and tell that the dynamic users are going to be created with all privileges to the database for the sake of the demo:

```bash
vault write database/roles/verinotes \
    db_name="verinotes-postgres" \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"
```

Now we need another policy and role to consume the dynamic secret:


```bash
vault policy write verinotes-postgres - <EOF
path "database/roles/verinotes" {
  capabilities = {"read"}
}
EOF

vault write auth/kubernetes/role/vso-verinotes-dynamic \
   bound_service_account_names=verinotes \
   bound_service_account_namespaces=verinotes \
   policies=verinotes-postgres \
   audience=vault \
   ttl=24h
```

Ok, after all this setup we finally have both a static and a dynamic secrets in Vault, we can finally move onto installing the operator and then finally the demo application.
