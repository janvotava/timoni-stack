# Timoni Stack

## Modules

- `postgresql` - PostgreSQL database
- `miniflux` - Miniflux RSS reader
- `cilium-network-policy` - Generic Cilium network policy for pod-to-pod traffic control

## Bundles

- `miniflux-stack` - PostgreSQL + Miniflux

```shell
DB_PASSWORD=your-db-password \
ADMIN_PASSWORD=your-admin-password \
INGRESS_HOST=miniflux.example.com \
timoni bundle apply -f bundles/miniflux-stack.cue --runtime-from-env
```
