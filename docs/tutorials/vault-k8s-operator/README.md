# Quick Run

This README is meant to provide a quick run through the scenario for demos etc. when you want to move fast or set up an environment before hand.

There are few duplicate Vault CLI commands, but most files are directly embedded into the website markdown files to make updating/maintaining easier.

## Install Vault

```bash
./install-vault.sh
```

## Setup K8s Auth

```bash
./enable-auth.sh
```

## KV2 setup

```bash
./kv2-config.sh
```

## Postgres + Database Secrets config

```bash
kubectl create namespace verinotes
kubectl apply -f postgres.yaml
./database-config.sh
```

## VSO + Connection + Auth

```bash
./install-vso.sh
kubectl apply -f vault-connection.yaml -f vault-auth.yaml
```

## Now it's probably demo time...

See [verinotes.md](verinotes.md)
