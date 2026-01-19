package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#StatefulSet: appsv1.#StatefulSet & {
	#config:     #Config
	#secretname: string

	apiVersion: "apps/v1"
	kind:       "StatefulSet"
	metadata:   #config.metadata

	spec: appsv1.#StatefulSetSpec & {
		serviceName: #config.metadata.name
		replicas:    #config.replicas
		selector: matchLabels: #config.selector.labels
		template: {
			metadata: {
				labels: #config.selector.labels
				if #config.pod.annotations != _|_ {
					annotations: #config.pod.annotations
				}
			}
			spec: corev1.#PodSpec & {
				containers: [
					{
						name:            "postgres"
						image:           #config.image.reference
						imagePullPolicy: #config.image.pullPolicy
						ports: [
							{
								name:          "psql"
								containerPort: 5432
								protocol:      "TCP"
							},
						]

						env: [
							{
								name:  "POSTGRES_USER"
								value: #config.user
							},
							{
								name:  "PGUSER"
								value: #config.user
							},
							{
								name:  "POSTGRES_DB"
								value: #config.database
							},
							{
								name:  "PGDATABASE"
								value: #config.database
							},
							{
								name: "POSTGRES_PASSWORD"
								valueFrom: secretKeyRef: {
									name: #secretname
									key:  "pgpassword"
								}
							},
							{
								name:  "PGDATA"
								value: "/var/lib/postgresql/data/pgdata"
							},
							if #config.initdbArgs != _|_ {
								{
									name:  "POSTGRES_INITDB_ARGS"
									value: #config.initdbArgs
								}
							},
							if #config.initdbWalDir != _|_ {
								{
									name:  "POSTGRES_INITDB_WALDIR"
									value: #config.initdbWalDir
								}
							},
						]

						startupProbe: {
							exec: command: ["/bin/sh", "-c", "pg_isready"]
							periodSeconds:    5
							failureThreshold: 30
						}
						readinessProbe: {
							exec: command: [
								"/bin/sh",
								"-c",
								"pg_isready && exit 0 || (exit_code=$?; if [ $exit_code -le 1 ]; then exit 0; else exit $exit_code; fi)",
							]
							periodSeconds:    5
							failureThreshold: 1
						}
						livenessProbe: {
							exec: command: ["/bin/sh", "-c", "pg_isready"]
							periodSeconds:    5
							failureThreshold: 3
						}
						volumeMounts: [{
							name:      "pgdata"
							mountPath: "/var/lib/postgresql/data"
						}]
						if #config.resources != _|_ {
							resources: #config.resources
						}
						if #config.securityContext != _|_ {
							securityContext: #config.securityContext
						}
					},
				]
				if #config.pod.affinity != _|_ {
					affinity: #config.pod.affinity
				}
				if #config.pod.imagePullSecrets != _|_ {
					imagePullSecrets: #config.pod.imagePullSecrets
				}
				if !#config.storage.persistent {
					volumes: [{
						name: "pgdata"
						emptyDir: sizeLimit: #config.storage.size
					}]
				}
			}
		}
		if #config.storage.persistent {
			persistentVolumeClaimRetentionPolicy: #config.storage.retainPolicy
			volumeClaimTemplates: [{
				metadata: {
					name:   "pgdata"
					labels: #config.storage.labels
					if #config.storage.annotations != _|_ {
						annotations: #config.storage.annotations
					}
				}
				spec: corev1.#PersistentVolumeClaimSpec & {
					accessModes: ["ReadWriteOnce"]
					resources: requests: storage: #config.storage.size
				}
			}]
		}
	}
}
