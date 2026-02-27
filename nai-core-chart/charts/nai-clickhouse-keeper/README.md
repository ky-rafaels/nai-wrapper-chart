# NAI ClickHouse Keeper Helm Chart

This directory contains helm charts to deploy the ClickHouse Clusters for NAI across Kubernetes environments.

ClickHouse Keeper is one of important components required for ClickHouse to run in distributed setup.

The following components must be deployed before ClickHouse Server in order for the server to work as expected.

1. `nai-clickhouse-operator`

### Directory Structure
The top level directory of your repository should be set up like this:
1. `README.md`: This file contains a textual description of the repository.
2. `templates`: This directory has helm templates needed for deploying ClickHouse Keeper.
3. `Chart.yaml`: Chart.yaml for helm chart
4. `values.yaml`: User provided values to configure ClickHouse Keeper deployment.

### Resources

ClickHouse Keeper Helm Chart currently deploys the following resources:
1. A ClickHouseKeeperInstallation custom resource (CR). The altinity-clickhouse-operator monitors and renders this CR into appropriate resources which make up the ClickHouse Keeper component.
2. A ServiceMonitor custom resource (CR) which is rendered by Prometheus operator running in the cluster to fetch details about how to scrape metrics for keeper.

#### Custom Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `namespace` | string | `""` | Namespace to deploy resources |
| `nameOverride` | string | `nai-clickhouse-keeper` | Override the keeper identifier |
| `clickhouseKeeper.labels` | map | `{}` | Additional labels for ClickHouse Keeper pods |
| `clickhouseKeeper.annotations` | map | `{}` | Additional annotations for ClickHouse Keeper pods |
| `clickhouseKeeper.clusterName` | string | `chkeeper` | Cluster name for ClickHouse Keeper |
| `clickhouseKeeper.replicas` | int | `1` | Number of ClickHouse Keeper replicas |
| `clickhouseKeeper.image.registry` | string | `docker.io` | Docker registry URL for image |
| `clickhouseKeeper.image.repository` | string | `nutanix/nai-clickhouse-keeper` | Docker image repository name |
| `clickhouseKeeper.image.tag` | string | `25.3.5.42` | Docker image tag/version |
| `clickhouseKeeper.image.imagePullPolicy` | string | `IfNotPresent` | Image pull policy |
| `clickhouseKeeper.service.type` | string | `ClusterIP` | Kubernetes Service type |
| `clickhouseKeeper.service.ports` | list | `[]` | List of service ports; default ports (client/metrics) are added automatically |
| `clickhouseKeeper.imagePullSecrets` | list | `[]` | List of image pull secrets for pods |
| `clickhouseKeeper.metrics.enabled` | bool | `true` | Enable/disable metrics collection |
| `clickhouseKeeper.metrics.path` | string | `/metrics` | Metrics endpoint path |
| `clickhouseKeeper.metrics.port` | int | `7000` | Metrics port |
| `clickhouseKeeper.metrics.asyncMetrics` | bool | `true` | Enable/disable asynchronous metrics |
| `clickhouseKeeper.settings.logLevel` | string | `trace` | Log level for ClickHouse Keeper |
| `clickhouseKeeper.settings.raftLogLevel` | string | `information` | Log level for Raft protocol |
| `clickhouseKeeper.settings.logToConsole` | bool | `true` | Enable/disable logging to console |
| `clickhouseKeeper.settings.clientTcpPort` | int | `2181` | TCP port for client connections |
| `clickhouseKeeper.extraEnvVars` | list | `[]` | Additional environment variables for Keeper pods |
| `clickhouseKeeper.storage.storageClassName` | string | `""` | Storage class for PersistentVolumeClaim |
| `clickhouseKeeper.storage.pvcStorage` | string | `"10Gi"` | Size for PersistentVolumeClaim |
| `clickhouseKeeper.storage.accessModes` | list | `["ReadWriteOnce"]` | Access modes for PersistentVolumeClaim |
| `clickhouseKeeper.storage.reclaimPolicy` | string | `"Retain"` | Reclaim policy for PersistentVolumeClaim (Retain or Delete) |
| `clickhouseKeeper.resources.requests.cpu` | string | `100m` | CPU request for Keeper pod |
| `clickhouseKeeper.resources.requests.memory` | string | `128Mi` | Memory request for Keeper pod |
| `clickhouseKeeper.resources.limits.cpu` | string | `200m` | CPU limit for Keeper pod |
| `clickhouseKeeper.resources.limits.memory` | string | `256Mi` | Memory limit for Keeper pod |
| `clickhouseKeeper.priorityClassName` | string | `""` | PriorityClass for Keeper pods |
| `clickhouseKeeper.nodeSelector` | list | `[]` | Node selector for scheduling Keeper pods |
| `clickhouseKeeper.podAntiAffinity` | map | `{}` | Pod anti-affinity rules (type: "hard"/"soft", topologyKey) |
| `clickhouseKeeper.tolerations` | list | `[]` | Pod tolerations for Keeper pods |
| `clickhouseKeeper.additionalSettings` | map | `{}` | Additional custom settings for Keeper |
| `serviceMonitor.enabled` | bool | `true` | Enable ServiceMonitor CRD for Prometheus |

### ClickHouse Keeper Deployment

1. **Configure values:**
   Edit `values.yaml` to match your environment requirements (namespace, image repository, resources, etc).

2. **Install the Helm chart:**
   ```bash
   helm install ntnx-nai nai-clickhouse-keeper -n <namespace> --create-namespace
   ```

3. **Verify deployment:**
   ```bash
   kubectl get pods -n <namespace>
   ```

### Upgrading

To upgrade the keeper, update the chart and run:
```bash
helm upgrade ntnx-nai nai-clickhouse-keeper -n <namespace>
```