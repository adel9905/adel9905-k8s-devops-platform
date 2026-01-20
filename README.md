# 🚀 Kubernetes DevOps Platform (EKS + CI/CD + Monitoring)

A **production-grade DevOps platform** built on **AWS EKS**, demonstrating **end-to-end CI/CD**, **Infrastructure as Code**, **security scanning**, and **observability** using **Jenkins, Terraform, SonarQube, Trivy, Prometheus, and Grafana**.

This project simulates **real-world DevOps/SRE workflows** and best practices used in enterprise environments.

---

## 🧭 Architecture Overview

```
Developer
   |
   | Git Push
   v
GitHub Repository
   |
   | Jenkins Pipeline
   v
+----------------------------+
| Jenkins CI/CD              |
|                            |
| ✔ Terraform Validate       |
| ✔ SonarQube Code Scan      |
| ✔ Docker Build             |
| ✔ Trivy Security Scan      |
| ✔ Deploy to EKS            |
+----------------------------+
                |
                v
        AWS EKS (Kubernetes)
                |
     +------------------------+
     | Workloads + Policies  |
     | - Deployments         |
     | - HPA                 |
     | - ResourceQuota       |
     | - LimitRange          |
     +------------------------+
                |
                v
     Prometheus + Grafana
     (Monitoring & Metrics)
```

---

## 🧰 Tech Stack

| Category | Tools |
|-------|------|
| Cloud | **AWS (EKS, EC2, IAM, VPC)** |
| IaC | **Terraform** |
| CI/CD | **Jenkins (Declarative Pipeline)** |
| Containers | **Docker** |
| Kubernetes | **EKS, kubectl** |
| Code Quality | **SonarQube** |
| Security | **Trivy (image scanning)** |
| Monitoring | **Prometheus + Grafana (Helm)** |
| OS | **Linux (Ubuntu)** |

---

## 📂 Repository Structure

```
.
├── Dockerfile
├── Jenkinsfile
├── kubernetes/
│   ├── namespace.yaml
│   ├── limitrange.yaml
│   ├── resourcequota.yaml
│   ├── deployment.yaml
│   ├── hpa.yaml
│   ├── pod.yaml
│   └── replicaset.yaml
├── monitoring/
│   └── install.sh
├── tf_code/
│   ├── eks.tf
│   ├── nodegroup.tf
│   ├── vpc.tf
│   └── iam.tf
├── tools/
├── .dockerignore
├── .gitignore
└── README.md
```

---

## 🔄 CI/CD Pipeline Stages

1. Checkout Source Code  
2. Verify Tooling  
3. Terraform Validate (CI Safe)  
4. Configure kubeconfig (EKS)  
5. SonarQube Code Scan  
6. Docker Image Build  
7. Trivy Image Security Scan  
8. Deploy to Kubernetes  
9. Monitoring Setup (Prometheus + Grafana)

---

## ☸️ Kubernetes Best Practices Implemented

- ResourceQuota & LimitRange
- CPU & Memory Requests/Limits
- Horizontal Pod Autoscaler (HPA)
- Multi-container Pods
- Init Containers
- In this project, Kubernetes manifests are designed to run workloads in a controlled, scalable, and fair way.
I defined a namespace to isolate resources. I used a LimitRange and ResourceQuota to enforce CPU and memory allocations at both container and namespace levels, preventing noisy neighbors and cluster starvation, a common real-world concern in shared clusters.
Deployment manifests define desired workload state and replicas, while HPA ensures automatic scaling based on real-time usage. These configurations align with enterprise best practices for resource governance, resilience, and cost optimization

---

## 🔊 Noisy Neighbor Prevention

- Enforced CPU & memory limits
- Namespace-level quotas
- Real-time visualization in Grafana
- Prevents one workload from starving others

---

## 📊 Monitoring & Observability

- Installed via Helm: kube-prometheus-stack
- Prometheus, Grafana, Node Exporter, kube-state-metrics
- Kubernetes Global & Node dashboards

---

## 🔐 Security & Quality

- SonarQube for static analysis (code + IaC)
- Trivy for container image vulnerability scanning
- Pipeline fails on HIGH/CRITICAL issues

---

## 🚀 How to Run

```bash
cd tf_code
terraform init
terraform apply
```

```bash
aws eks update-kubeconfig --region ap-south-1 --name staging-demo
```

Trigger Jenkins pipeline.

Access Grafana:
```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

Open: http://127.0.0.1:3000

---

## 🎯 Interview Value

- Real enterprise DevOps workflow
- CI/CD + Kubernetes + Security + Observability
- Production-grade patterns

---

## 👨‍💻 Author

**Adel Ahmed**  
Cloud / DevOps Engineer  
Warsaw, Poland
