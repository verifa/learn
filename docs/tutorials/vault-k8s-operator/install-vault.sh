helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm upgrade vault hashicorp/vault --namespace vault \
	--create-namespace \
	--install \
	--values=vault-values.yaml \
	--version=0.25.0
