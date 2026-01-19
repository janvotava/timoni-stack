# postgresql

A [timoni.sh](http://timoni.sh) module for deploying PostgreSQL to Kubernetes clusters.

## Install

To create an instance using the default values:

```shell
timoni -n default apply postgresql oci://<container-registry-url> \
--values password=<your-secure-password>
```

To change the [default configuration](#configuration),
create one or more `values.cue` files and apply them to the instance.

For example, create a file `my-values.cue` with the following content:

```cue
values: {
 password: "my-secure-password"
 user:     "myapp"
 database: "myapp"
 storage: {
  size:       "10Gi"
  persistent: true
 }
 resources: requests: {
  cpu:    "100m"
  memory: "256Mi"
 }
}
```

And apply the values with:

```shell
timoni -n default apply postgresql oci://<container-registry-url> \
--values ./my-values.cue
```

## Uninstall

To uninstall an instance and delete all its Kubernetes resources:

```shell
timoni -n default delete postgresql
```

## Configuration

### PostgreSQL values

| Key                      | Type                             | Default              | Description                                                                                                              |
| ------------------------ | -------------------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `password:`              | `string` (required)              | -                    | PostgreSQL password (required)                                                                                           |
| `user:`                  | `string`                         | `postgres`           | PostgreSQL user                                                                                                          |
| `database:`              | `string`                         | `postgres`           | PostgreSQL database name                                                                                                 |
| `initdbArgs:`            | `string`                         | -                    | Optional arguments to postgres initdb (e.g., "--data-checksums")                                                         |
| `initdbWalDir:`          | `string`                         | -                    | Optional location for Postgres transaction log                                                                           |
| `image: tag:`            | `string`                         | `18`                 | PostgreSQL image tag                                                                                                     |
| `image: repository:`     | `string`                         | `docker.io/postgres` | Container image repository                                                                                               |
| `image: digest:`         | `string`                         | `""`                 | Container image digest, takes precedence over `tag` when specified                                                       |
| `image: pullPolicy:`     | `string`                         | `IfNotPresent`       | [Kubernetes image pull policy](https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy)                 |
| `replicas:`              | `int`                            | `1`                  | Number of PostgreSQL replicas                                                                                            |
| `service: port:`         | `int`                            | `5432`               | PostgreSQL service port                                                                                                  |
| `service: annotations:`  | `{[ string]: string}`            | `{}`                 | Annotations applied to the Kubernetes Service                                                                            |
| `storage: size:`         | `resource.Quantity`              | `1Gi`                | Storage size for PostgreSQL data                                                                                         |
| `storage: persistent:`   | `bool`                           | `true`               | Use persistent storage (PVC) or emptyDir                                                                                 |
| `storage: retainPolicy:` | `{whenDeleted, whenScaled}`      | `Retain/Retain`      | PVC retention policy                                                                                                     |
| `storage: labels:`       | `{[ string]: string}`            | `{}`                 | Labels for PVC                                                                                                           |
| `storage: annotations:`  | `{[ string]: string}`            | `{}`                 | Annotations for PVC                                                                                                      |
| `metadata: labels:`      | `{[ string]: string}`            | `{}`                 | Common labels for all resources                                                                                          |
| `metadata: annotations:` | `{[ string]: string}`            | `{}`                 | Common annotations for all resources                                                                                     |
| `pod: annotations:`      | `{[ string]: string}`            | `{}`                 | Annotations applied to pods                                                                                              |
| `pod: affinity:`         | `corev1.#Affinity`               | `{}`                 | [Kubernetes affinity and anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)        |
| `pod: imagePullSecrets:` | `[...timoniv1.ObjectReference]`  | `[]`                 | [Kubernetes image pull secrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets)      |
| `resources:`             | `timoniv1.#ResourceRequirements` | -                    | [Kubernetes resource requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| `securityContext:`       | `corev1.#SecurityContext`        | -                    | [Kubernetes container security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context)       |
