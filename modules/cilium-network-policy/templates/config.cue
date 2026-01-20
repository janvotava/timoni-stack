package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// The kubeVersion is a required field, set at apply-time
	// via timoni.cue by querying the user's Kubernetes API.
	kubeVersion!: string
	// Using the kubeVersion you can enforce a minimum Kubernetes minor version.
	// By default, the minimum Kubernetes version is set to 1.20.
	clusterVersion: timoniv1.#SemVer & {#Version: kubeVersion, #Minimum: "1.20.0"}

	// The moduleVersion is set from the user-supplied module version.
	// This field is used for the `app.kubernetes.io/version` label.
	moduleVersion!: string

	// The Kubernetes metadata common to all resources.
	// The `metadata.name` and `metadata.namespace` fields are
	// set from the user-supplied instance name and namespace.
	metadata: timoniv1.#Metadata & {#Version: moduleVersion}

	// The labels allows adding `metadata.labels` to all resources.
	// The `app.kubernetes.io/name` and `app.kubernetes.io/version` labels
	// are automatically generated and can't be overwritten.
	metadata: labels: timoniv1.#Labels

	// The annotations allows adding `metadata.annotations` to all resources.
	metadata: annotations?: timoniv1.#Annotations

	// The selector defines which pods this network policy applies to.
	// Must be explicitly specified to target the correct pods.
	selector: labels: [string]: string

	// Ingress rules - who can connect to this service
	ingress: {
		rules: [string]: #IngressRule
	}

	// Egress rules - where this service can connect to
	egress: {
		// Allow DNS lookups
		allowDNS: *true | bool

		// Custom egress rules
		rules: [string]: #EgressRule
	}
}

// IngressRule defines an ingress rule for the network policy
#IngressRule: {
	// Labels to match source pods
	fromLabels: [string]: string

	// Optional: namespace of source pods
	fromNamespace?: string

	// Ports that the source can access
	toPorts: [...{
		port:     string | int
		protocol: *"TCP" | "UDP" | "ANY"
	}]
}

// EgressRule defines an egress rule for the network policy
#EgressRule: {
	// Labels to match destination pods (optional if toEntities is specified)
	toLabels?: [string]: string

	// Optional: namespace of destination pods
	toNamespace?: string

	// Optional: entities to allow egress to (e.g., "world" for external traffic)
	toEntities?: [...string]

	// Ports that can be accessed (optional - if not specified, all ports allowed)
	toPorts?: [...{
		port:     string | int
		protocol: *"TCP" | "UDP" | "ANY"
	}]
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		policy: #CiliumNetworkPolicy & {#config: config}
	}
}
