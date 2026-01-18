# Grafana Dashboards

This project uses **Grafana** to visualize metrics collected by Prometheus.

## Available Dashboards
The following dashboards are imported directly from Grafana community:

- Kubernetes Cluster Overview (ID: 15757)
- Kubernetes Pods (ID: 15760)
- Node Exporter Full (ID: 1860)
- HPA Metrics (ID: 16110)

## Importing Dashboards
1. Open Grafana UI
2. Click **+ → Import**
3. Enter Dashboard ID
4. Select **Prometheus** as datasource

## Future Enhancement
Dashboards can be managed as code using ConfigMaps and automatically loaded into Grafana.

# Monitoring & Observability

This project uses **Prometheus, Grafana, and Alertmanager** for full Kubernetes observability.

## Components
- **Prometheus** – Metrics collection
- **Grafana** – Visualization & dashboards
- **Alertmanager** – Alert handling and routing

## Installation
```bash
./install.sh