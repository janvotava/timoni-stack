package templates

import (
	ciliumv2 "cilium.io/ciliumnetworkpolicy/v2"
)

#CiliumNetworkPolicy: ciliumv2.#CiliumNetworkPolicy & {
	#config: #Config
	metadata: {
		name:      #config.metadata.name
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
		if #config.metadata.annotations != _|_ {
			annotations: #config.metadata.annotations
		}
	}
	spec: {
		// Select pods using the same labels as the service
		endpointSelector: matchLabels: #config.selector.labels

		// Ingress rules - who can connect to this service
		ingress: [
			// Custom ingress rules
			for ruleName, rule in #config.ingress.rules {
				{
					fromEndpoints: [{
						matchLabels: rule.fromLabels
						if rule.fromNamespace != _|_ {
							matchLabels: "io.kubernetes.pod.namespace": rule.fromNamespace
						}
					}]
					toPorts: [{
						ports: [for p in rule.toPorts {
							port:     "\(p.port)"
							protocol: p.protocol
						}]
					}]
				}
			},
		]

		// Egress rules - where this service can connect to
		egress: [
			// Optionally allow DNS lookups
			if #config.egress.allowDNS {
				{
					toEndpoints: [{
						matchLabels: {
							"io.kubernetes.pod.namespace": "kube-system"
							"k8s-app":                     "kube-dns"
						}
					}]
					toPorts: [{
						ports: [{
							port:     "53"
							protocol: "ANY"
						}]
					}]
				}
			},
			// Custom egress rules
			for ruleName, rule in #config.egress.rules {
				{
					if rule.toLabels != _|_ {
						toEndpoints: [{
							matchLabels: rule.toLabels
							if rule.toNamespace != _|_ {
								matchLabels: "io.kubernetes.pod.namespace": rule.toNamespace
							}
						}]
					}
					if rule.toEntities != _|_ {
						toEntities: rule.toEntities
					}
					if rule.toPorts != _|_ {
						toPorts: [{
							ports: [for p in rule.toPorts {
								port:     "\(p.port)"
								protocol: p.protocol
							}]
						}]
					}
				}
			},
		]
	}
}
