# NAI easy install

## Purpose

This is a wrapper helm chart for the purpose of installing NAI and all its dependent components

## Dependencies

- All NAI images need to exist in a private image registry somewhere
- Private registry should have necessary TLS trust configured for images to be pulled

## Usage

Fetch dependent charts for kserve, api gateway and OTEL

```bash
helm dependency update
```

Update custom values

```bash
cat << EOF > custom-values.yaml
global:
  repository: "harbor.example.com/nutanix"
  nkpWorkspaceNamespace: "nai-system"
gatewayCrdsHelm:
  crds:
    gatewayAPI:
      enabled: true
    envoyGateway:
      enabled: true
gatewayHelm:
  global:
    imagePullSecrets:
      - name: regcred
kserve:
  controller:
    deploymentMode: RawDeployment
    gateway:
      disableIngressCreation: true
    image: "nai-kserve-controller"
    rbacProxyImage: "nai-kserve-rbac-proxy:v0.18.0"
    imagePullSecrets:
      - name: regcred
EOF
```
