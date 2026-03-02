# NAI Easy Install

A GitOps-ready Helm chart framework for deploying [Nutanix AI (NAI)](https://www.nutanix.com/products/ai) and all its dependent components on Kubernetes. Managed via [Flux CD](https://fluxcd.io/).

## Overview

This repository provides three umbrella Helm charts that together install the full NAI stack, deployed in order via Flux HelmReleases:

| Chart | Purpose |
|-------|---------|
| `nai-dependent-chart` | External infrastructure dependencies (Envoy Gateway, KServe, OpenTelemetry) |
| `nai-operators-chart` | Kubernetes operators and CRDs (ClickHouse, AI Gateway) |
| `nai-core-chart` | NAI application services (API, UI, IAM, monitoring, ClickHouse, inference runtimes) |

## Architecture

```
nai-easy-install (GitOps root)
├── flux/
│   ├── git-repo.yaml              # Flux GitRepository source
│   ├── nai-dependencies/hr.yaml   # HelmRelease: external dependencies
│   ├── nai-operators/hr.yaml      # HelmRelease: operators & CRDs
│   └── nai-core/hr.yaml           # HelmRelease: NAI services
├── nai-dependent-chart/           # Envoy Gateway, KServe, OpenTelemetry
├── nai-operators-chart/           # ClickHouse operator, AI Gateway operator
└── nai-core-chart/                # Full NAI service stack
```

## Prerequisites

- Kubernetes cluster (AKS, EKS, GKE, NKP, or Kind supported)
- [Flux CD](https://fluxcd.io/flux/installation/) bootstrapped on the cluster
- A private image registry with all NAI images mirrored
- Image pull secret (`regcred`) created in the target namespace

## Quick Start

### 1. Configure values

Each chart has a `custom-values.yaml` for environment-specific overrides. At minimum, update the image registry:

```bash
# Example: nai-dependent-chart/custom-values.yaml
gateway-helm:
  deployment:
    envoyGateway:
      image:
        repository: "harbor.example.com/nutanix/nai-gateway"
        tag: "v1.5.0"
kserve:
  kserve:
    controller:
      image: "harbor.example.com/nutanix/nai-kserve-controller"
```

Platform-specific value files are provided for common distributions:

| File | Platform |
|------|---------|
| `nai-core-chart/aks-values.yaml` | Azure AKS |
| `nai-core-chart/eks-values.yaml` | AWS EKS |
| `nai-core-chart/gke-values.yaml` | Google GKE |
| `nai-core-chart/kind-values.yaml` | Kind (local dev) |

### 2. Apply Flux resources

```bash
kubectl apply -f flux/git-repo.yaml
kubectl apply -f flux/nai-dependencies/
kubectl apply -f flux/nai-operators/
kubectl apply -f flux/nai-core/
```

Flux will reconcile all three HelmReleases into the `nai-system` namespace.

### 3. Install manually (without Flux)

```bash
# 1. External dependencies
helm dependency update ./nai-dependent-chart
helm upgrade --install nai-dependencies --create-namespace -n nai-system \
  -f nai-dependent-chart/custom-values.yaml ./nai-dependent-chart

# 2. Operators
helm dependency update ./nai-operators-chart
helm upgrade --install nai-operators -n nai-system \
  -f nai-operators-chart/custom-values.yaml ./nai-operators-chart

# 3. Core services
helm dependency update ./nai-core-chart
helm upgrade --install nai -n nai-system \
  -f nai-core-chart/custom-values.yaml ./nai-core-chart
```

## Component Versions

### External Dependencies (`nai-dependent-chart`)

| Component | Version |
|-----------|---------|
| Envoy Gateway CRDs | v1.5.1 |
| Envoy Gateway | v1.5.1 |
| KServe | v0.15.0 |
| KServe CRDs | v0.15.0 |
| OpenTelemetry Operator | 0.93.0 |

### Operators (`nai-operators-chart`)

| Component | Version |
|-----------|---------|
| ClickHouse Operator | 0.24.2 |
| AI Gateway | c4f26a8 |

### Core Services (`nai-core-chart`)

| Component | Version |
|-----------|---------|
| NAI API / UI / IAM | v2.5.0 |
| KServe HuggingFace Runtime | v0.15.2 |
| VLLM Runtime | v0.10.2 |
| TGI Runtime | 3.3.4 |
| ClickHouse | 25.3.5.42 |
| OpenTelemetry Collector | 0.136.0 |
| OAuth2 Proxy | v7.9.0 |

## Flux GitOps

The `flux/` directory contains the Flux CD resources. The `GitRepository` polls this repo on a 10-minute interval:

```yaml
# flux/git-repo.yaml
url: https://github.com/ky-rafaels/nai-wrapper-chart
ref:
  branch: main
```

Each `HelmRelease` references its chart by path within the repo and uses `valuesFiles` to load `custom-values.yaml` from the chart directory.

## Storage Requirements

| Component | Default Size | Access Mode |
|-----------|-------------|-------------|
| NAI Database (PostgreSQL) | 4Gi | RWO |
| ClickHouse Server | 50Gi | RWO |
| OTel Collector | 1Gi | RWO |
| NAI Labs (RAG) | 20Gi | RWX |

Storage class names are configurable per environment via platform-specific values files.

## Image Registry

All NAI images must be mirrored to a private registry before deployment. Images are sourced from `docker.io/nutanix/` by default and can be overridden in each chart's `custom-values.yaml`.

The registry URL pattern used throughout the charts:

```
harbor.example.com/nutanix/<image-name>:<tag>
```

## License

Copyright (c) Nutanix, Inc. All rights reserved. Use of this software is governed by the Nutanix License Agreement. See [Nutanix Legal](https://www.nutanix.com/legal) for details.
