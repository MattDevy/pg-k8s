# Check to see if we can use ash, in Alpine images, or default to BASH.
SHELL_PATH = /bin/ash
SHELL = $(if $(wildcard $(SHELL_PATH)),/bin/ash,/bin/bash)

# ==============================================================================
# Define dependencies

KIND            := kindest/node:v1.30.0

KIND_CLUSTER    := pg-cluster
NAMESPACE       := postgres-example

# ==============================================================================
# Install dependencies

dev-brew:
	brew update
	brew list kind || brew install kind
	brew list kubectl || brew install kubectl
	brew list pgcli || brew install pgcli
	brew list watch || brew install watch
	brew list helm || brew install helm
	brew list k9s || brew install k9s

# ==============================================================================
# Running from within k8s/kind

dev-up:
	kind create cluster \
		--image $(KIND) \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/dev/kind-config.yaml

	kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner

	helm repo add cnpg https://cloudnative-pg.github.io/charts
	helm upgrade --install cnpg \
		--namespace cnpg-system \
		--create-namespace \
		--wait \
		cnpg/cloudnative-pg

	# See: https://github.com/cloudnative-pg/charts/blob/main/charts/cluster/README.md
	helm upgrade --install database \
		--namespace database \
		--create-namespace \
		--set cluster.monitoring.enabled=true \
		--set cluster.monitoring.prometheusRule.enabled=false \
		--wait \
		cnpg/cluster

dev-down:
	kind delete cluster --name $(KIND_CLUSTER)
