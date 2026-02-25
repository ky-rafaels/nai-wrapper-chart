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


```
