---
title: Configure KV2 Secret Engine
---

Since we're running the Vault in `dev` mode, there's already a `kv` v2 engine mounted, but let's create a new one just for the demo.

## Enable Key Value v2 Secret Engine

Now let's enable/create a KV v2 secrets engine and add some secrets there for us to consume:

```bash
vault secrets enable -path=kvv2 kv-v2
```

Next let's create a policy that allows reading all the secrets in the new KV store:

```bash
vault policy write full-access - <<EOF
path "kvv2/*" {
   capabilities = ["read"]
}
EOF
```

!!! info
    Note that it's bit more involved when specifying a certain path in the `kv` v2 store, we're sort of cheating here not worrying about the different actions and data vs metadata etc. just to not overwhelm anyone. See the ACL docs to see how you could modify this to be more specific: <https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2#acl-rules>

Next we need a role for the Vault Secrets Operator, we'll naturally assign the previously created policy to this role:

```bash
vault write auth/kubernetes/role/vso-verinotes-static \
   bound_service_account_names=verinotes \
   bound_service_account_namespaces=verinotes \
   policies=full-access \
   audience=vault \
   ttl=24h
```

Note that we bind the `verinotes` ServiceAccount with access to the role, we will later create this ServiceAccount.

Let's write some secrets too of course:

```bash
vault kv put kvv2/verinotes/config username="static-user" password="static-password"
```

That's it for the static secrets, next let's setup Dynamic Secrets for a PostgresQL server.

