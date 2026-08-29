# Envoy Configuration

## Static Configuration (envoy.yaml)

The main configuration file is `envoy.yaml` located at `/etc/envoy/envoy.yaml`.

### Admin Interface

```yaml
admin:
  access_log_path: /var/log/envoy/admin_access.log
  address:
    socket_address:
      address: 127.0.0.1
      port_value: 19000
```

### Static Resources

```yaml
static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 8080
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: service_cluster }
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router

  clusters:
  - name: service_cluster
    connect_timeout: 5s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: service_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8081
```

### Dynamic Configuration (xDS)

For dynamic configuration, set the config path:

```yaml
config_path: /etc/envoy/envoy.yaml
bootstrap_config_path: /etc/envoy/bootstrap.json
```

### File Locations

| System | Config Path |
|--------|-------------|
| Linux (systemd) | `/etc/envoy/envoy.yaml` |
| Windows | `C:\envoy\envoy.yaml` |

### Hot Restart

Envoy supports hot restart for zero-downtime deployments:

```yaml
# In your envoy.yaml
hot_restart_version: 2
hot_restart_args:
  - --hot-restart-version
  - 2
```

### Admin Access

```bash
# View cluster stats
curl http://localhost:19000/stats

# View clusters
curl http://localhost:19000/clusters

# View listeners
curl http://localhost:19000/listeners

# View routes
curl http://localhost:19000/routes
```

### Resources

- [Envoy Configuration Reference](https://www.envoyproxy.io/docs/envoy/latest/configuration/overview)
- [HTTP Connection Manager](https://www.envoyproxy.io/docs/envoy/latest/configuration/listeners/http_filters/router_filter)
- [Clusters and Load Balancing](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview)
- [Admin Interface](https://www.envoyproxy.io/docs/envoy/latest/operations/admin)