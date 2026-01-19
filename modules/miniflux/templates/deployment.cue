package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#Deployment: appsv1.#Deployment & {
	#config:     #Config
	#secretName: string
	apiVersion:  "apps/v1"
	kind:        "Deployment"
	metadata:    #config.metadata
	spec: appsv1.#DeploymentSpec & {
		replicas: #config.replicas
		selector: matchLabels: #config.selector.labels
		template: {
			metadata: {
				labels: #config.selector.labels
				if #config.podAnnotations != _|_ {
					annotations: #config.podAnnotations
				}
			}
			spec: corev1.#PodSpec & {
				containers: [
					{
						name:            #config.metadata.name
						image:           #config.image.reference
						imagePullPolicy: #config.image.pullPolicy
						ports: [
							{
								name:          "http"
								containerPort: 8080
								protocol:      "TCP"
							},
						]
						env: [
							{
								name: "DATABASE_URL"
								valueFrom: secretKeyRef: {
									name: #secretName
									key:  "database-url"
								}
							},
							if #config.runMigrations {
								{
									name:  "RUN_MIGRATIONS"
									value: "1"
								}
							},
							if #config.admin.create {
								{
									name:  "CREATE_ADMIN"
									value: "1"
								}
							},
							if #config.admin.create {
								{
									name:  "ADMIN_USERNAME"
									value: #config.admin.username
								}
							},
							if #config.admin.create {
								{
									name: "ADMIN_PASSWORD"
									valueFrom: secretKeyRef: {
										name: #secretName
										key:  "admin-password"
									}
								}
							},
						]
						livenessProbe: {
							httpGet: {
								path: "/healthcheck"
								port: "http"
							}
							initialDelaySeconds: 30
							periodSeconds:       10
						}
						readinessProbe: {
							httpGet: {
								path: "/healthcheck"
								port: "http"
							}
							initialDelaySeconds: 10
							periodSeconds:       5
						}
						resources:       #config.resources
						securityContext: #config.securityContext
					},
				]
				if #config.podSecurityContext != _|_ {
					securityContext: #config.podSecurityContext
				}
				if #config.topologySpreadConstraints != _|_ {
					topologySpreadConstraints: #config.topologySpreadConstraints
				}
				if #config.affinity != _|_ {
					affinity: #config.affinity
				}
				if #config.tolerations != _|_ {
					tolerations: #config.tolerations
				}
				if #config.imagePullSecrets != _|_ {
					imagePullSecrets: #config.imagePullSecrets
				}
			}
		}
	}
}
