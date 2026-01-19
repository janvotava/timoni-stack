# miniflux

A [timoni.sh](http://timoni.sh) module for deploying [Miniflux](https://miniflux.app/), a minimalist and opinionated feed reader.

## Install

To create an instance using custom values:

```shell
timoni -n default apply miniflux oci://<container-registry-url> \
  --values ./values.cue
```

## Configuration

### Required Values

- `database.url`: PostgreSQL database connection string
- `admin.password`: Admin user password

### Example values.cue

```cue
values: {
  image: {
    repository: "docker.io/miniflux/miniflux"
    tag:        "latest"
  }

  database: {
    url: "postgres://miniflux:secret@postgresql/miniflux?sslmode=disable"
  }

  admin: {
    create:   true
    username: "admin"
    password: "changeme"
  }

  runMigrations: true

  service: {
    port: 80
  }

  resources: requests: {
    cpu:    "100m"
    memory: "128Mi"
  }
}
```

## Uninstall

To uninstall an instance and delete all its Kubernetes resources:

```shell
timoni -n default delete miniflux
```

## Configuration Reference

### Miniflux-specific values

| Key                   | Type     | Default                                                     | Description                                    |
|-----------------------|----------|-------------------------------------------------------------|------------------------------------------------|
| `database.url`        | `string` | `postgres://miniflux:secret@postgresql/miniflux?sslmode=disable` | PostgreSQL connection string (required)        |
| `admin.create`        | `bool`   | `true`                                                      | Create admin user on startup                   |
| `admin.username`      | `string` | `admin`                                                     | Admin username                                 |
| `admin.password`      | `string` | `changeme`                                                  | Admin password (required)                      |
| `runMigrations`       | `bool`   | `true`                                                      | Run database migrations on startup             |

### General values

| Key                          | Type                                    | Default                         | Description                                                                                                                                  |
|------------------------------|-----------------------------------------|---------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `image.tag`                  | `string`                                | `latest`                        | Container image tag                                                                                                                          |
| `image.digest`               | `string`                                | `""`                            | Container image digest, takes precedence over `tag` when specified                                                                           |
| `image.repository`           | `string`                                | `docker.io/miniflux/miniflux`   | Container image repository                                                                                                                   |
| `image.pullPolicy`           | `string`                                | `IfNotPresent`                  | [Kubernetes image pull policy](https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy)                                     |
| `metadata.labels`            | `{[string]: string}`                    | `{}`                            | Common labels for all resources                                                                                                              |
| `metadata.annotations`       | `{[string]: string}`                    | `{}`                            | Common annotations for all resources                                                                                                         |
| `podAnnotations`             | `{[string]: string}`                    | `{}`                            | Annotations applied to pods                                                                                                                  |
| `replicas`                   | `int`                                   | `1`                             | Number of pod replicas                                                                                                                       |
| `resources`                  | `timoniv1.#ResourceRequirements`        | `{requests: {cpu: "10m", memory: "32Mi"}}` | [Kubernetes resource requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers)                     |
| `service.port`               | `int`                                   | `80`                            | Kubernetes Service HTTP port                                                                                                                 |

## Dependencies

Miniflux requires a PostgreSQL database. You can deploy PostgreSQL using the `postgresql` module in this repository.
