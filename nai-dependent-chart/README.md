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
  nkpWorkspaceNamespace: "nai-system"
gateway-crds-helm:
  crds:
    gatewayAPI:
      enabled: true
    envoyGateway:
      enabled: true
gateway-helm:
  deployment:
    envoyGateway:
      image:
        repository: "harbor.example.com/nutanix/nai-gateway"
        tag: "v1.5.0"
  global:
    images:
      naiProxy: 
        image: "harbor.example.com/nutanix/nai-envoy:distroless-v1.35.0"
      ratelimit: 
        image: "harbor.example.com/nutanix/nai-ratelimit:3e085e5b"
    imagePullSecrets:
      - name: regcred
kserve:
  kserve:
    controller:
      deploymentMode: RawDeployment
      gateway:
        disableIngressCreation: true
      image: "harbor.example.com/nutanix/nai-kserve-controller"
      rbacProxyImage: "harbor.example.com/nutanix/nai-kserve-rbac-proxy:v0.18.0"
      imagePullSecrets:
        - name: regcred
EOF
```

Then install

```bash
helm upgrade --install nai-dependencies --create-namespace ./nai-dependent-chart
```
