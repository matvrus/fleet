#!/bin/bash

kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml

flux create source git flux-monitoring \
  --interval=30m \
  --url=https://github.com/matvrus/fleet.git \
  --branch=main

flux create kustomization kube-prometheus-stack \
  --interval=1h \
  --prune \
  --source=flux-monitoring \
  --path="./manifests/monitoring/kube-prometheus-stack" \
  --health-check-timeout=5m \
  --wait

flux create kustomization loki-stack \
  --depends-on=kube-prometheus-stack \
  --interval=1h \
  --prune \
  --source=flux-monitoring \
  --path="./manifests/monitoring/loki-stack" \
  --health-check-timeout=5m \
  --wait

flux create kustomization monitoring-config \
  --depends-on=kube-prometheus-stack \
  --interval=1h \
  --prune=true \
  --source=flux-monitoring \
  --path="./manifests/monitoring/monitoring-config" \
  --health-check-timeout=1m \
  --wait

flux create kustomization otel \
  --depends-on=kube-prometheus-stack \
  --interval=1h \
  --prune=true \
  --source=flux-monitoring \
  --path="./manifests/monitoring/otel" \
  --health-check-timeout=1m \
  --wait

flux create source git open-telemetry \
  --url=https://github.com/matvrus/fleet \
  --branch=main \
  --interval=1m

flux create kustomization open-telemetry \
  --source=open-telemetry \
  --path="./open-telemetry" \
  --prune=true \
  --validation=client \
  --interval=5m

flux create source git grafana \
  --url=https://github.com/matvrus/fleet \
  --branch=main \
  --interval=1m
flux create kustomization grafana \
  --source=grafana \
  --path="./grafana" \
  --prune=true \
  --validation=client \
  --interval=5m

flux create source git tempo \
  --url=https://github.com/matvrus/fleet \
  --branch=main \
  --interval=1m
flux create kustomization tempo \
  --source=tempo \
  --path="./tempo" \
  --prune=true \
  --validation=client \
  --interval=5m

flux create source git loki \
  --url=https://github.com/matvrus/fleet \
  --branch=main \
  --interval=1m
flux create kustomization loki \
  --source=loki \
  --path="./loki" \
  --prune=true \
  --validation=client \
  --interval=5m

flux create source git prometheus \
  --url=https://github.com/matvrus/fleet \
  --branch=main \
  --interval=1m
flux create kustomization prometheus \
  --source=prometheus \
  --path="./prometheus" \
  --prune=true \
  --validation=client \
  --interval=5m

flux create source git fluent-bit \
  --url=https://github.com/matvrus/fleet \
  --branch=main \
  --interval=1m
flux create kustomization fluent-bit \
  --source=fluent-bit \
  --path="./fluent-bit" \
  --prune=true \
  --validation=client \
  --interval=5m

flux start --network=default
