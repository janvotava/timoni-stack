# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Timoni stack repository for deploying applications on Kubernetes. Timoni is a package manager for Kubernetes that uses CUE for configuration. The repository contains reusable modules and bundles that compose multiple modules together.

## Repository Structure

- `modules/` - Reusable Timoni modules
  - `postgresql` - PostgreSQL database
  - `miniflux` - Miniflux RSS reader
  - `cilium-network-policy` - Generic Cilium network policy module
- `bundles/` - Bundle definitions that compose multiple modules together
- Each module contains:
  - `timoni.cue` - Main entrypoint that defines the schema and workflow
  - `values.cue` - Default values for the module
  - `debug_values.cue` - Values used for local testing/development
  - `debug_tool.cue` - CUE commands for building and inspecting manifests
  - `templates/` - CUE definitions for Kubernetes resources (config.cue defines #Config schema and #Instance)
  - `cue.mod/` - CUE module dependencies (includes k8s.io schemas and timoni.sh core types)

## Key Concepts

### Modules
Each module follows the Timoni module structure:
- `templates/config.cue` defines the `#Config` schema (configuration options) and `#Instance` (outputs Kubernetes objects)
- `timoni.cue` imports templates and wires user values into the instance
- Resources are defined in separate template files (e.g., `statefulset.cue`, `deployment.cue`, `service.cue`, `secret.cue`, `ingress.cue`)

### Bundles
Bundles compose multiple module instances together:
- Define runtime parameters using `@timoni(runtime:string:VAR_NAME)` annotations
- Reference modules via `module: url: "file://../modules/modulename"`
- Pass values to each instance under `instances.<name>.values`
- Can share values between instances (e.g., database credentials passed from postgresql to miniflux)

## Development Commands

### Testing a Module
```bash
# Validate module structure and schema
timoni mod vet ./modules/postgresql

# Build and preview manifests using CUE commands
cd modules/postgresql
cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build

# List resources that would be created
cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 ls
```

### Applying a Bundle
```bash
# Apply bundle with runtime values from environment variables
DB_PASSWORD=your-db-password \
ADMIN_PASSWORD=your-admin-password \
INGRESS_HOST=miniflux.example.com \
timoni bundle apply -f bundles/miniflux-stack.cue --runtime-from-env
```

### Working with Timoni CLI
```bash
# Build a bundle (dry-run)
timoni bundle build -f bundles/miniflux-stack.cue

# Apply a module directly
timoni apply <instance-name> ./modules/postgresql -n <namespace> -f values.yaml

# Inspect applied instances
timoni list -A

# Delete an instance
timoni delete <instance-name> -n <namespace>
```

## CUE Module Structure

Each module's `cue.mod/` contains:
- `module.cue` - Defines the module name (e.g., `module: "timoni.sh/postgresql"`)
- `gen/` - Auto-generated Kubernetes API schemas from k8s.io
- `pkg/timoni.sh/core/v1alpha1/` - Timoni core types (#Config, #Image, #Metadata, #Selector, etc.)

## Code Patterns

### Adding a New Module
1. Create `modules/<name>/` directory
2. Initialize with `timoni mod init <name>`
3. Define schema in `templates/config.cue` (#Config and #Instance)
4. Create resource templates in `templates/` (deployment.cue, service.cue, etc.)
5. Set defaults in `values.cue`
6. Add debug values in `debug_values.cue` for local testing
7. Validate with `timoni mod vet ./modules/<name>`

### Adding a Resource to a Module
1. Create `templates/<resource>.cue` with a definition like `#Deployment`, `#Service`, etc.
2. Add the resource to `#Instance.objects` in `templates/config.cue`
3. Reference #config and pass necessary values from the config schema

### Creating a Bundle
1. Create `bundles/<name>.cue`
2. Define runtime parameters with `@timoni(runtime:string:VAR_NAME)`
3. Add instances under `instances:` with module URLs and values
4. Use private fields (prefixed with `_`) for runtime values that are referenced in instance configs

### Using Cilium Network Policy Module
The `cilium-network-policy` module creates CiliumNetworkPolicy resources for controlling pod-to-pod traffic. Key features:
- **Custom selector labels**: Target any pods by specifying `selector.labels`
- **Ingress rules**: Control who can connect to the selected pods
- **Egress rules**: Control where the selected pods can connect
- **DNS support**: Optional DNS egress via `egress.allowDNS` (enabled by default)
- **External traffic**: Use `toEntities: ["world"]` for internet access
- **Optional ports**: Ports can be omitted to allow all ports (useful for external traffic)

Example usage in a bundle:
```cue
"app-network-policy": {
    module: url: "file://../modules/cilium-network-policy"
    namespace: "myapp"
    values: {
        selector: labels: {
            "app.kubernetes.io/name": "myapp"
        }
        ingress: {
            rules: {
                "allow-nginx": {
                    fromLabels: {"app.kubernetes.io/name": "nginx"}
                    fromNamespace: "ingress"
                    toPorts: [{port: 8080, protocol: "TCP"}]
                }
            }
        }
        egress: {
            allowDNS: true
            rules: {
                "allow-db": {
                    toLabels: {"app.kubernetes.io/name": "postgresql"}
                    toPorts: [{port: 5432, protocol: "TCP"}]
                }
                "allow-internet": {
                    toEntities: ["world"]  // No toPorts = all ports allowed
                }
            }
        }
    }
}
```

### Vendoring CRDs
For modules that use custom resources (like CiliumNetworkPolicy), vendor the CRD for proper type validation:
```bash
cd modules/<module-name>
timoni mod vendor crd -f <crd-url>
```
This generates CUE types in `cue.mod/gen/` that can be imported and used for compile-time validation.
