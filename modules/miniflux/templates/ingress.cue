package templates

import (
	netv1 "k8s.io/api/networking/v1"
)

#Ingress: netv1.#Ingress & {
	#config:    #Config
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata:   #config.metadata
	metadata: {
		if #config.ingress.labels != _|_ {
			labels: #config.ingress.labels
		}
		if #config.ingress.annotations != _|_ {
			annotations: #config.ingress.annotations
		}
	}
	spec: netv1.#IngressSpec & {
		rules: [{
			host: #config.ingress.host
			http: {
				paths: [{
					pathType: "Prefix"
					path:     "/"
					backend: service: {
						name: #config.metadata.name
						port: name: "http"
					}
				}]
			}
		}]
		if #config.ingress.tls {
			tls: [{
				hosts: [#config.ingress.host]
				secretName: "\(#config.metadata.name)-cert"
			}]
		}
		if #config.ingress.className != _|_ {
			ingressClassName: #config.ingress.className
		}
	}
}
