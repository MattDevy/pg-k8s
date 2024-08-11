# PG-k8s
Randomly testing out https://cloudnative-pg.io on local Kind set up.
Were using two helm charts, one to install the operator and CRD (custom resource definitions) and the other to install a cluster.

## Getting started
### Install tooling
Install any tooling needed with brew (assuming Mac)

```sh
make dev-brew
```

If not running on mac, look up each tool and the installation instructions for your specific OS.

### Spin up the cluster
```sh
make dev-up
```

### Look around using k9s
```sh
k9s
```

Find the "database" namespace, and looks at the various resources in it.

## Accessing the database
### Find the secret(s)
```sh
export PSQL_USER=postgres
export PSQL_PASS=$(kubectl get secrets -n database database-cluster-superuser -o jsonpath='{.data.password}' | base64 -d)

echo $PSQL_PASS
```

### Port forward to the service (in a new tab)
```sh
kubectl port-forward -n database svc/database-cluster-rw 5432:5432
```

### Connect with pgcli
```sh
echo $PSQL_PASS
pgcli -h localhost -p 5432 -u $PSQL_USER -W
# Enter the password from above
```

## Cleanup
```sh
make dev-down
```

## Further work
- add metrication, monitoring and alerting to this stack using proemtheus and grafana.
- add a demo application that uses this deployment
- use fluxcd or kustomize to deploy instead of helm




