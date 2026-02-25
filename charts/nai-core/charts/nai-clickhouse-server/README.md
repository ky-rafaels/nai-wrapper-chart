# NAI ClickHouse Server Helm Chart

This directory contains helm charts to deploy the Clickhouse Clusters for NAI across Kubernetes environments.

The following components must be deployed before Clickhouse Server in order for the server to work as expected.

1. `nai-clickhouse-operator`
2. `nai-clickhouse-keeper`

### Directory Structure
The top level directory of your repository should be set up like this:
1. `README.md`: This file contains a textual description of the repository.
2. `templates`: This directory has helm templates needed for deploying ClickHouse Server.
3. `Chart.yaml`: Chart.yaml for helm chart
4. `values.yaml`: User provided values to configure ClickHouse Server deployment.

### Resources

ClickHouse Server Helm Chart currently deploys the following resources:
1. A ClickHouseInstallation custom resource (CR). The altinity-clickhouse-operator monitors and renders this CR into appropriate resources which make up the ClickHouse Server component.
2. A Kubernetes secret object containing details of admin credentials required to perform administration operations on the CH server.
3. A Kubernetes configmap which stores shards and replicas configuration for the CH server. The data defined in this configmap is consumed by ClickHouse schema job setup schemas on the server.

#### Custom Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `namespace` | string | `""` | Namespace for ClickHouse deployment |
| `nameOverride` | string | `nai-clickhouse-server` | Identifier for clickhouse server |
| `clickhouse.labels` | map | `{}` | Additional labels for ClickHouse server deployment |
| `clickhouse.annotations` | map | `{}` | Additional annotations for ClickHouse server deployment |
| `clickhouse.shards` | int | `1` | Number of shards in the ClickHouse cluster |
| `clickhouse.replicas` | int | `1` | Number of replicas per shard in the ClickHouse cluster |
| `clickhouse.image.registry` | string | `docker.io` | ClickHouse image registry |
| `clickhouse.image.repository` | string | `nutanix/nai-clickhouse-server` | ClickHouse image repository |
| `clickhouse.image.tag` | string | `25.3.5.42` | ClickHouse image tag |
| `clickhouse.clusterName` | string | `chcluster1` | ClickHouse cluster identifier |
| `clickhouse.priorityClassName` | string | `""` | PriorityClass for ClickHouse server pods |
| `clickhouse.nodeSelector` | map | `{}` | Node selector for scheduling ClickHouse server pods |
| `clickhouse.podAntiAffinity` | map | `{}` | Pod anti-affinity rules (type: "hard"/"soft", topologyKey) |
| `clickhouse.tolerations` | list | `[]` | Pod tolerations for ClickHouse server |
| `clickhouse.keeperClusterService.name` | string | `clickhouse-chk-svc` | Keeper cluster service name |
| `clickhouse.keeperClusterService.port` | int | `2181` | Keeper cluster service TCP port |
| `clickhouse.storage.storageClass` | string | `""` | Storage class for ClickHouse server PVC |
| `clickhouse.storage.pvcStorage` | string | `"100Gi"` | PVC storage size for ClickHouse server |
| `clickhouse.storage.accessModes` | list | `["ReadWriteOnce"]` | Access modes for the persistent volume claim (PVC) |
| `clickhouse.storage.reclaimPolicy` | string | `"Retain"` | Reclaim policy for the persistent volume claim (PVC). Values can be Retain or Delete |
| `clickhouse.users.default.username` | string | `default` | Default ClickHouse user name |
| `clickhouse.users.default.password` | string | `default` | Default ClickHouse user password |
| `clickhouse.users.admin.username` | string | `admin` | Admin ClickHouse user name |
| `clickhouse.users.admin.password` | string | `admin` | Admin ClickHouse user password |
| `clickhouse.extraEnvVars` | list | `[]` | Extra environment variables for ClickHouse server pods |
| `clickhouse.resources.limits.cpu` | string | `2` | CPU limit for ClickHouse server pod |
| `clickhouse.resources.limits.memory` | string | `8Gi` | Memory limit for ClickHouse server pod |
| `clickhouse.resources.requests.cpu` | string | `2` | CPU request for ClickHouse server pod |
| `clickhouse.resources.requests.memory` | string | `8Gi` | Memory request for ClickHouse server pod |
| `clickhouse.service.type` | string | `ClusterIP` | Service type for ClickHouse server |
| `clickhouse.service.ports` | list | `see values.yaml` | Service ports for ClickHouse server (http, tcp, prom) |
| `clickhouse.imagePullSecrets` | list | `[]` | Image pull secrets for ClickHouse server pods |
| `clickhouse.initContainers.waitForKeeper.enabled` | bool | `false` | Enable init container to wait for ClickHouse Keeper readiness |
| `clickhouse.initContainers.waitForKeeper.image.registry` | string | `docker.io` | Init container image registry |
| `clickhouse.initContainers.waitForKeeper.image.repository` | string | `nutanix/nai-jobs` | Init container image repository (nai-jobs with netcat) |
| `clickhouse.initContainers.waitForKeeper.image.tag` | string | `latest` | Init container image tag |
| `clickhouse.initContainers.waitForKeeper.timeoutSeconds` | int | `600` | Timeout in seconds to wait for ClickHouse Keeper to be ready |
| `clickhouse.initContainers.waitForKeeper.intervalSeconds` | int | `15` | Interval in seconds between health checks |
| `clickhouse.initContainers.waitForKeeper.resources` | map | `see values.yaml` | Resource specifications for the init container |
| `clickhouse.serverConfigurations.users` | map | `{}` | Custom user settings for ClickHouse server |
| `clickhouse.serverConfigurations.profiles` | map | `see values.yaml` | Custom profile settings for ClickHouse server |
| `clickhouse.serverConfigurations.settings` | map | `see values.yaml` | General server settings for ClickHouse server |
| `clickhouse.serverConfigurations.files` | map | `see values.yaml` | Custom XML config files for ClickHouse server |

### Init Container for ClickHouse Keeper Dependency

The ClickHouse Server chart includes an optional init container that ensures ClickHouse Keeper pods are ready before starting the ClickHouse Server. This prevents connection issues and ensures proper cluster initialization.

#### Features:
- **Optional**: Can be enabled/disabled via `clickhouse.initContainers.waitForKeeper.enabled`
- **Ultra-lightweight**: Uses nai-jobs image with netcat pre-installed
- **Zero runtime dependencies**: No package installation needed - netcat ready to use
- **Airgapped friendly**: Works in any environment (online, airgapped, restricted) without internet access
- **Battle-tested**: Uses the same `echo ruok | nc` approach that works in manual testing
- **Simple & Reliable**: Direct netcat health check without Kubernetes API dependencies
- **Configurable**: Adjustable timeout and check interval
- **Resource efficient**: Minimal CPU/memory footprint
- **No RBAC required**: No additional permissions needed

#### How it works:
1. **Direct TCP Connection**: Uses nai-job's built-in `netcat` to connect directly to ClickHouse Keeper service
2. **Health Protocol**: Sends `ruok` command and waits for `imok` response (standard ClickHouse Keeper health check)
3. **Retry Logic**: Checks every 15 seconds (configurable) until timeout is reached
4. **Zero Runtime Dependencies**: Uses pre-installed netcat - no package installation required
5. **Startup Control**: Only after ClickHouse Keeper responds with `imok`, the ClickHouse Server container starts
6. **Timeout Protection**: If timeout is reached without healthy response, init container fails and prevents server startup

#### Usage:
To enable the init container, set the following in your values.yaml:
```yaml
clickhouse:
  initContainers:
    waitForKeeper:
      enabled: true
      timeoutSeconds: 600    # Optional: adjust timeout as needed (default: 600s)
      intervalSeconds: 15    # Optional: adjust check interval (default: 15s)
```

The init container works out-of-the-box in any environment - no additional configuration needed for airgapped or restricted environments!

### ClickHouse Server Deployment

1. Update the `values.yaml` to define the ClickHouse Server specifications

2. To install the helm chart, execute the following command:

```bash
helm install -f values.yaml nai-clickhouse-server . --namespace <namespace>
```

## Administration

For performing administration tasks, please use the credentials defined in the Kubernetes secret `ch-admin`.