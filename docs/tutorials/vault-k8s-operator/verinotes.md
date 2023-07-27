---
title: Demo Application
---

We are going to use the magnificent VeriNotes application to test the dynamic secrets when it connects to the Postgres database, but before that let's take a look at the static secrets by just inspecting if we can create a Kubernetes Secret with the values from Vault.

Since we're going to be running a lot of commands to poke the app, it's best to now switch into the `verinotes` namespace by default:

```bash
kubectl config set-context --current --namespace=verinotes
```

## Static Secrets

You guessed it, more YAML! Let's create now the resource that will actually reference something in Vault `VaultStaticSecret`:

```yaml title="static-secret.yaml"
--8<-- "tutorials/vault-k8s-operator/static-secret.yaml"
```

Apply the resource:

```bash
kubectl apply -f static-secret.yaml
```

### Verify the Secret is Created

When testing this I noticed it was taking almost 2 minutes for the `Secret` to be created, but your experience might be different. Check if the secret is created:

```bash
kubectl get secrets -n verinotes
```

You should see a secret called `static-secret`, if not try to search the logs of the operator to see if there are errors or it just has not happened yet:

```bash
kubectl logs deployment/vault-secrets-operator-controller-manager -n vso-system
```

The important events to look for are "Secret synced" and "Successfully handled VaultAuth resource request", between these two it took quite some time but that's probably going to be fixed in future releases.

Once the secret is there, you can verify it matches the values you set:


```bash
echo "username: $(kubectl get secret static-secret -n verinotes -o jsonpath='{.data.username}' | base64 -d) \
	password: $(kubectl get secret static-secret -n verinotes -o jsonpath='{.data.password}' | base64 -d)"
```

There's nothing too exciting about this, so let's next setup the demo application and it will use a dynamic secret to connect to the Postgres database.


## Dynamic Secrets

Next we will create a dynamic secret, the only real difference is that the value won't remain static but will be rotated by the operator according to the TTL.

Also dynamic secrets have their own CR `VaultDynamicSecret`:

```yaml title="dynamic-secret.yaml" hl_lines="16-18"
--8<-- "tutorials/vault-k8s-operator/dynamic-secret.yaml"
```

Note the highlighted part, because the secret is dynamic the operator provides us means to rotate the secret with `rollout restart` which we will later see in action.

Apply the resource:

```bash
kubectl apply -f dynamic-secret.yaml
```

Now this will already create a secret which will be auto-rotated by the operator whenever needed (according to TTL). You can see if the secret is synced, you should wait for it to be created before continuing.

```bash
kubectl get secret vso-postgres-creds
```


### Deploying VeriNotes

Now deploy VeriNotes `Deployment`:

```yaml title="verinotes-deployment.yaml"
--8<-- "tutorials/vault-k8s-operator/verinotes-deployment.yaml"
```

Apply:

```bash
kubectl apply -f verinotes-deployment.yaml
```

VeriNotes will by default print out the full connection string for the database, including password and username. This is of course extremely bad for a production application, but VeriNotes is meant for demo purposes:

```bash
kubectl logs deploy/verinotes-deployment
```

You can also visit the website if you like to, but it's not mandatory since the logs show the values being injected. But if you want:

```bash
open http://localhost:3000 && kubectl port-forward deploy/verinotes-deployment 3000:3000
```

### Rotating Secret

As stated earlier, we configured the Vault Operator to also do a rolling restart on the `Deployment` whenever the secret is rotated, this seems to work nicely and you can see that before the TTL (1 minute), a new pod will come up and the old one will be terminated (once new is up and running of course):

```bash
verinotes-deployment-668c668897-k9zr4   0/1     Terminating   0          44s
verinotes-deployment-7bc7df7dd6-nfr4w   1/1     Running       0          2s
```

This is quite neat, because the connection to the database will terminate when the user is removed by Vault in the backend (when it's time to rotate). In the demo the TTL is very short, you probably want to use a higher value in production to reduce load on your Kubernetes API server and Vault.

### Environment Variables vs File Mounts

It's also worthy to note that VeriNotes uses environment values to receive the secret, this is not ideal actually. The most secure way to consume secrets is from a memory backed (tmpfs is used by default for secrets!) volume as files, kubelet will also update the file contents without restarting the pod. Let's demostrate this:

Apply:

```bash
kubectl apply -f alpine-deployment.yaml
```

Observe the values, after a minute or so the value should change:


```bash
kubectl exec -it deployment/alpine-deployment -- cat /postgres-secret/username
kubectl exec -it deployment/alpine-deployment -- cat /postgres-secret/password
```

Note that the pod stays running, this is because in the `VaultDynamicSecret` resource we only told to rotate the `verinotes-deployment`.

For VeriNotes the rotation does not matter since VeriNotes is unable to read secrets from file and frankly it should be fine to rollout new pods when needed instead of adding the logic to renew the connection to the postgres in the application code. But it's good to know the values can be rotated without a restart if you implement hot reloading of the values in your app! Naturally, `ConfigMap`s will rotate/update the same way when mounted as volumes.
