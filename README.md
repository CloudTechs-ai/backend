# Med Pharma Backend

Production-oriented **Spring Boot microservices platform** powering the Med Pharma application. The backend is built with **Java 17**, containerized with Docker, deployed to **AWS EKS**, and managed through a **GitOps workflow with ArgoCD**.

The platform is designed around independently deployable services, automated security scanning, infrastructure as code, and environment promotion through Git.

## 🏗️ Architecture

```text
                                      ┌──────────────────────┐
                                      │      End Users       │
                                      │  Web / API Clients   │
                                      └──────────┬───────────┘
                                                 │
                                                 ▼
                                      ┌──────────────────────┐
                                      │     AWS ALB /        │
                                      │   Ingress Controller  │
                                      └──────────┬───────────┘
                                                 │
                                                 ▼
                              ┌──────────────────────────────────┐
                              │          AWS EKS Cluster          │
                              │                                  │
                              │   ┌──────────────────────────┐   │
                              │   │       API Gateway         │   │
                              │   │  Spring Cloud Gateway     │   │
                              │   │          :8080            │   │
                              │   └────────────┬─────────────┘   │
                              │                │                 │
                              │      ┌─────────┼─────────┐       │
                              │      │         │         │       │
                              │      ▼         ▼         ▼       │
                              │  ┌────────┐ ┌────────┐ ┌────────┐│
                              │  │  Auth  │ │  Drug  │ │Inventory││
                              │  │ :8081  │ │Catalog │ │ :8083  ││
                              │  └────┬───┘ │ :8082  │ └────┬───┘│
                              │       │     └────┬───┘      │    │
                              │       │          │          │    │
                              │       ▼          ▼          ▼    │
                              │  ┌────────────────────────────────┐
                              │  │          PostgreSQL / RDS       │
                              │  │                                │
                              │  │  Auth │ Catalog │ Inventory     │
                              │  │  Manufacturing │ Supplier       │
                              │  └────────────────────────────────┘
                              │                                  │
                              │  ┌──────────────┐ ┌──────────────┐│
                              │  │Manufacturing │ │   Supplier   ││
                              │  │    :8084     │ │    :8085     ││
                              │  └──────────────┘ └──────────────┘│
                              │                                  │
                              │  ┌──────────────────────────────┐│
                              │  │     Notification Service      ││
                              │  │      Node.js / Express :8086  ││
                              │  └──────────────────────────────┘│
                              └──────────────────────────────────┘
                                                 │
                                                 ▼
                                      ┌──────────────────────┐
                                      │ Notification Providers│
                                      │     Email / SMS       │
                                      └──────────────────────┘


     ┌────────────────────────────────────────────────────────────────┐
     │                         GitOps / CI-CD                         │
     │                                                                │
     │  Developer                                                     │
     │      │                                                         │
     │      ▼                                                         │
     │  GitHub ──► GitHub Actions                                     │
     │                │                                               │
     │                ├── Gitleaks                                    │
     │                ├── Maven / Tests / JaCoCo                      │
     │                ├── CodeQL                                      │
     │                ├── Semgrep                                     │
     │                ├── OWASP Dependency Check                      │
     │                ├── Docker Build                                │
     │                ├── Trivy                                       │
     │                ├── Cosign                                      │
     │                └── Push Image ───────────────► AWS ECR         │
     │                                                                │
     │                              │                                 │
     │                              ▼                                 │
     │                         med-gitops                             │
     │                              │                                 │
     │                              ▼                                 │
     │                           ArgoCD                               │
     │                              │                                 │
     │                              ▼                                 │
     │                         AWS EKS                                │
     └────────────────────────────────────────────────────────────────┘
```

### Architecture Flow

```text
Developer
   │
   ▼
GitHub Repository
   │
   ▼
GitHub Actions
   │
   ├── Test
   ├── Security Scan
   ├── Build
   ├── Container Scan
   └── Sign Image
   │
   ▼
AWS ECR
   │
   ▼
Med-gitops
   │
   ▼
ArgoCD
   │
   ▼
AWS EKS
   │
   ├── API Gateway
   ├── Auth Service
   ├── Drug Catalog
   ├── Inventory
   ├── Manufacturing
   ├── Supplier
   └── Notifications
   │
   ▼
Amazon RDS PostgreSQL
```

## ☁️ Platform Overview

| Layer               | Technology                       |
| ------------------- | -------------------------------- |
| Application         | Java 17 / Spring Boot            |
| API Gateway         | Spring Cloud Gateway             |
| Notifications       | Node.js 20 / Express             |
| Containers          | Docker                           |
| Orchestration       | Kubernetes / AWS EKS             |
| Database            | PostgreSQL / Amazon RDS          |
| Container Registry  | Amazon ECR                       |
| Infrastructure      | Terraform                        |
| CI/CD               | GitHub Actions                   |
| GitOps              | ArgoCD                           |
| Security            | Gitleaks, CodeQL, Semgrep, Trivy |
| Dependency Security | OWASP Dependency-Check           |
| Image Signing       | Cosign / Sigstore                |
| AWS Authentication  | GitHub OIDC                      |

## 🧩 Microservices

The platform consists of seven independently deployable backend services.

| Service           | Responsibility                                           |   Port | Database   |
| ----------------- | -------------------------------------------------------- | -----: | ---------- |
| **API Gateway**   | External API routing and service entry point             | `8080` | —          |
| **Auth Service**  | Authentication, JWT issuance, and user management        | `8081` | PostgreSQL |
| **Drug Catalog**  | Drug search, categories, and formulary management        | `8082` | PostgreSQL |
| **Inventory**     | Inventory levels, replenishment, and batch tracking      | `8083` | PostgreSQL |
| **Manufacturing** | Production orders and pharmaceutical batch manufacturing | `8084` | PostgreSQL |
| **Supplier**      | Supplier management and purchase orders                  | `8085` | PostgreSQL |
| **Notification**  | Email and SMS notification processing                    | `8086` | —          |

Each service can be built, tested, containerized, and deployed independently.

## 🔄 CI/CD Pipeline

Changes to `develop` and `release/**` trigger the complete deployment pipeline.

```text
Commit
  │
  ▼
Secret Detection ──► Gitleaks
  │
  ▼
Build & Test ──────► Maven + Integration Tests
  │
  ▼
Coverage ──────────► JaCoCo ≥ 80%
  │
  ▼
SAST ──────────────► CodeQL + Semgrep
  │
  ▼
Dependency Scan ───► OWASP Dependency-Check
  │
  ▼
Container Build ───► Docker
  │
  ▼
Image Security ────► Trivy
  │
  ▼
Image Registry ────► Amazon ECR
  │
  ▼
Image Signing ─────► Cosign / Sigstore
  │
  ▼
GitOps Update ─────► med-gitops
  │
  ▼
ArgoCD Sync
  │
  ▼
AWS EKS
  │
  ▼
DEV Environment
  │
  ▼
QA Promotion PR
```

### Feature Branch Pipeline

Feature branches use a lightweight validation pipeline:

```text
Feature Branch
     │
     ├── Gitleaks
     ├── Tests
     ├── JaCoCo
     ├── CodeQL
     ├── Semgrep
     └── Dependency Check
```

Docker builds, ECR publishing, and deployment are intentionally excluded from feature branch validation.

## 🔐 Security Architecture

Security is integrated directly into the software delivery lifecycle.

### Application Security

* CodeQL SAST
* Semgrep security rules
* OWASP Top 10 detection
* OWASP Dependency-Check
* Gitleaks secret detection
* JaCoCo test coverage enforcement

### Container Security

* Multi-stage Docker builds
* Non-root container execution
* Trivy vulnerability scanning
* HIGH/CRITICAL vulnerability detection
* `ignore-unfixed` vulnerability policy

### Supply Chain Security

Container images are signed using **Cosign keyless signing** through GitHub OIDC, Fulcio, and Rekor.

```text
GitHub Actions
      │
      ▼
GitHub OIDC Identity
      │
      ▼
   Fulcio
      │
      ▼
Signed Container Image
      │
      ▼
    Rekor
```

### AWS Authentication

GitHub Actions authenticates to AWS using **OIDC federation** rather than storing long-lived AWS access keys in GitHub secrets.

```text
GitHub Actions
      │
      ▼
GitHub OIDC
      │
      ▼
AWS IAM Role
      │
      ▼
AWS Resources
```

## 🌎 Environment Promotion

Deployment follows a GitOps-based promotion model.

```text
Feature Branch
      │
      ▼
   develop
      │
      ▼
     DEV
      │
      ▼
   QA PR
      │
      ▼
  QA Environment
      │
      ▼
Manual PROD Promotion
      │
      ▼
    PROD
```

Production deployments are manually initiated through `promote-prod.yml`, providing an explicit promotion gate between environments.

## 🌿 Branching Strategy

| Branch       | Purpose                          | Pipeline                 |
| ------------ | -------------------------------- | ------------------------ |
| `feat/*`     | New feature development          | Lightweight CI           |
| `fix/*`      | Bug fixes                        | Lightweight CI           |
| `chore/*`    | Maintenance                      | Lightweight CI           |
| `develop`    | Integration                      | Full CI + DEV deployment |
| `release/**` | Release / hotfix                 | Full CI + DEV deployment |
| `main`       | Stable production-aligned branch | PR validation            |

## 📁 Repository Structure

```text
med-pharma-backend/
│
├── api-gateway/
├── auth-service/
├── drug-catalog-service/
├── inventory-service/
├── manufacturing-service/
├── notification-service/
├── supplier-service/
│
├── .github/
│   └── workflows/
│       ├── _java-build.yml
│       ├── _java-pr-check.yml
│       ├── _node-build.yml
│       ├── _node-pr-check.yml
│       │
│       ├── ci-api-gateway.yml
│       ├── ci-auth-service.yml
│       ├── ci-drug-catalog-service.yml
│       ├── ci-inventory-service.yml
│       ├── ci-manufacturing-service.yml
│       ├── ci-notification-service.yml
│       ├── ci-supplier-service.yml
│       │
│       ├── ci-pr-api-gateway.yml
│       ├── ci-pr-auth-service.yml
│       ├── ci-pr-drug-catalog-service.yml
│       ├── ci-pr-inventory-service.yml
│       ├── ci-pr-manufacturing-service.yml
│       ├── ci-pr-notification-service.yml
│       ├── ci-pr-supplier-service.yml
│       │
│       └── promote-prod.yml
│
└── README.md
```

## 🛠️ Local Development

### Prerequisites

* Java 17
* Maven 3.9+
* Docker Desktop
* PostgreSQL 15
* Git

### Run a Service

```bash
cd auth-service

docker run -d --name pharma-db \
  -e POSTGRES_DB=pharma \
  -e POSTGRES_USER=pharma \
  -e POSTGRES_PASSWORD=pharma \
  -p 5432:5432 \
  postgres:15-alpine

export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/pharma
export SPRING_DATASOURCE_USERNAME=pharma
export SPRING_DATASOURCE_PASSWORD=pharma
export JWT_SECRET=local-dev-secret

mvn spring-boot:run
```

### Run Tests

```bash
mvn verify
```

### Build a Container

```bash
docker build -t auth-service:local .
docker run -p 8081:8081 auth-service:local
```

## 🚀 Deployment Architecture

The platform is separated into three repositories following infrastructure, application, and configuration concerns.

```text
┌────────────────────┐
│   med-infra        │
│                    │
│ Terraform          │
│ AWS / EKS / RDS    │
│ IAM / ECR          │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ med-pharma-backend  │
│                    │
│ Microservices      │
│ CI/CD              │
│ Docker Images      │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│    med-gitops      │
│                    │
│ Helm Values        │
│ ArgoCD Apps        │
│ Environment Config │
└─────────┬──────────┘
          │
          ▼
       AWS EKS
```

### Companion Repositories

* **`med-infra`** — Terraform infrastructure for AWS, EKS, RDS, ECR, IAM, and supporting resources.
* **`med-pharma-frontend`** — React frontend application.
* **`med-gitops`** — Kubernetes/Helm configuration and ArgoCD applications.

## 🔑 Required GitHub Configuration

### Secrets

| Secret              | Purpose                                         |
| ------------------- | ----------------------------------------------- |
| `AWS_ACCOUNT_ID`    | AWS account identifier                          |
| `GITOPS_TOKEN`      | GitHub token for updating the GitOps repository |
| `SEMGREP_APP_TOKEN` | Semgrep Cloud authentication                    |
| `NVD_API_KEY`       | NIST vulnerability database API access          |

### Repository Variables

| Variable      | Value                                              |
| ------------- | -------------------------------------------------- |
| `GITOPS_REPO` | GitOps repository used for environment deployments |

## 🎯 Design Goals

The backend is designed around several core engineering principles:

* **Microservice isolation** — services can evolve and deploy independently.
* **Infrastructure as Code** — AWS infrastructure is managed through Terraform.
* **GitOps deployments** — Kubernetes state is managed declaratively through Git.
* **Automated security** — security scanning is part of every CI pipeline.
* **Immutable artifacts** — container images are versioned and signed before deployment.
* **Least-privilege access** — AWS authentication uses short-lived OIDC credentials.
* **Automated testing** — integration tests run against real PostgreSQL dependencies.
* **Environment promotion** — DEV, QA, and PROD deployments follow controlled promotion paths.
* **Cloud-native architecture** — workloads are containerized and orchestrated with Kubernetes on AWS EKS.

## 📌 Platform Summary

**Med Pharma** combines:

`Java 17` → `Spring Boot` → `Docker` → `AWS EKS` → `Amazon RDS` → `Terraform` → `GitHub Actions` → `ArgoCD` → `GitOps`

The result is a cloud-native backend platform with automated testing, security validation, container supply-chain controls, and Kubernetes-based deployment.
