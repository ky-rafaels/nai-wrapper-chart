# NAI ClickHouse Operator Helm Chart

This repository provides Helm charts and Kubernetes manifests for deploying the [Altinity ClickHouse Operator](https://github.com/Altinity/clickhouse-operator) for NAI. It includes custom configurations, dashboards, and automation for seamless integration with Kubernetes infrastructure.

## Features

- **Helm Chart**: Deploys the Altinity ClickHouse Operator with NAI specific defaults and best practices.
- **Dashboards**: Grafana dashboards for monitoring ClickHouse clusters, available in `files/`.
- **Prometheus Integration**: ServiceMonitor and PrometheusRule templates for metrics and alerting.
- **RBAC & Security**: Predefined roles, role bindings, and service accounts for secure operation.

## Getting Started

### Prerequisites

- Kubernetes cluster (v1.16+)
- [Helm 3.x](https://helm.sh/)

### Installation

1. **Configure values:**
   Edit `values.yaml` to match your environment requirements (namespace, image repository, resources, etc).

2. **Install the Helm chart:**
   ```sh
   helm install ntnx-nai nai-clickhouse-operator -n <namespace> --create-namespace
   ```

3. **Verify deployment:**
   ```sh
   kubectl get pods -n <namespace>
   ```

### Upgrading

To upgrade the operator, update the chart and run:
```sh
helm upgrade ntnx-nai nai-clickhouse-operator -n <namespace>
```

## Monitoring & Dashboards

- **Grafana Dashboards**: Import dashboards from `files/` into your Grafana instance.
- **Prometheus**: Metrics are exposed via the `ServiceMonitor` and can be scraped by Prometheus.

## Customization

- **Configuration**: Adjust `values.yaml` for custom resources, images, and NAI specific settings.
- **Additional Resources**: Use the `additionalResources` section in `values.yaml` to deploy extra Kubernetes resources alongside the operator.
- **Templates**: Extend or override templates in the `templates/` directory as needed.

## References

- [Altinity ClickHouse Operator Documentation](https://github.com/Altinity/clickhouse-operator)
- [ClickHouse Documentation](https://clickhouse.com/docs/en/)
- [Helm Documentation](https://helm.sh/docs/)