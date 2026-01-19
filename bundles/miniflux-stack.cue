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
	}
}
