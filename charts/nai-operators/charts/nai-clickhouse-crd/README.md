# NAI ClickHouse CRDs Helm Chart

This repository provides Helm charts for deploying the CRDs needed by ClickHouse Operator to manage ClickHouse Keeper and Server resources for NAI. 

## Features

- **Helm Chart**: Deploys the ClickHouse CRDs needed for ClickHouse Keeper (CHK) and Server (CHI).
- **Custom CRDs**: Includes CRDs for ClickHouseInstallation, ClickHouseInstallationTemplate, ClickHouseKeeperInstallation, and OperatorConfiguration. The CRDs are present under `templates` directory.

## Getting Started

### Prerequisites

- Kubernetes cluster (v1.16+)
- [Helm 3.x](https://helm.sh/)

### Installation

1. **Install the Helm chart:**
   ```sh
   helm install ntnx-nai nai-clickhouse-crd -n <namespace> --create-namespace
   ```

2. **Verify deployment:**
   ```sh
   kubectl get crds | grep clickhouse
   ```

### Upgrading

To upgrade the CRDs, update the chart and run:
```sh
helm upgrade ntnx-nai nai-clickhouse-crd -n <namespace>
```