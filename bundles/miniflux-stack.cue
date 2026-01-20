bundle: {
	apiVersion: "v1alpha1"
	name:       "miniflux-stack"
	#namespace: "miniflux"

	_dbPassword:    string @timoni(runtime:string:DB_PASSWORD)
	_adminPassword: string @timoni(runtime:string:ADMIN_PASSWORD)
	_ingressHost:   string @timoni(runtime:string:INGRESS_HOST)

	instances: {
		postgresql: {
			module: url: "file://../modules/postgresql"
			namespace: #namespace
			values: {
				image: {
					repository: "docker.io/postgres"
					tag:        "18"
					pullPolicy: "Always"
				}
				password: _dbPassword
				database: "miniflux"
				user:     "miniflux"
				storage: {
					size:       "1Gi"
					persistent: true
				}
			}
		}
		miniflux: {
			module: url: "file://../modules/miniflux"
			namespace: #namespace
			values: {
				image: {
					repository: "docker.io/miniflux/miniflux"
					tag:        "latest"
					pullPolicy: "Always"
				}
				database: {
					url: "postgres://miniflux:\(_dbPassword)@postgresql/miniflux?sslmode=disable"
				}
				admin: {
					username: "admin"
					password: _adminPassword
				}
				ingress: {
					enabled:   true
					className: "nginx"
					host:      _ingressHost
					tls:       true
					annotations: {
						"cert-manager.io/cluster-issuer": "letsencrypt"
					}
				}
			}
		}
		"postgresql-network-policy": {
			module: url: "file://../modules/cilium-network-policy"
			namespace: #namespace
			values: {
				selector: labels: {
					"app.kubernetes.io/name": "postgresql"
				}
				ingress: {
					rules: {
						"allow-miniflux": {
							fromLabels: {
								"app.kubernetes.io/name": "miniflux"
							}
							toPorts: [{
								port:     5432
								protocol: "TCP"
							}]
						}
					}
				}
				egress: {
					allowDNS: true
					rules: {}
				}
			}
		}
		"miniflux-network-policy": {
			module: url: "file://../modules/cilium-network-policy"
			namespace: #namespace
			values: {
				selector: labels: {
					"app.kubernetes.io/name": "miniflux"
				}
				ingress: {
					rules: {
						"allow-ingress": {
							fromLabels: {
								"app.kubernetes.io/component": "controller"
							}
							fromNamespace: "ingress"
							toPorts: [{
								port:     8080
								protocol: "TCP"
							}]
						}
					}
				}
				egress: {
					allowDNS: true
					rules: {
						"allow-postgresql": {
							toLabels: {
								"app.kubernetes.io/name": "postgresql"
							}
							toPorts: [{
								port:     5432
								protocol: "TCP"
							}]
						}
						"allow-feeds": {
							toEntities: ["world"]
						}
					}
				}
			}
		}
	}
}
