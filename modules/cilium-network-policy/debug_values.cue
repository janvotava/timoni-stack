@if(debug)

package main

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	selector: labels: {
		"app.kubernetes.io/name": "my-app"
	}
	ingress: {
		rules: {
			"allow-web": {
				fromLabels: {
					"app.kubernetes.io/name": "nginx-ingress"
				}
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
			"allow-postgres": {
				toLabels: {
					"app.kubernetes.io/name": "postgresql"
				}
				toNamespace: "database"
				toPorts: [{
					port:     5432
					protocol: "TCP"
				}]
			}
		}
	}
}
