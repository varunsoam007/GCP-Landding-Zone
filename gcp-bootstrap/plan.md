# GCP GitOps Baseline Implementation Plan

This document contains a detailed analysis of the Azure GitOps baseline architecture and a step-by-step implementation plan for building a similar, robust GitOps structure for Google Kubernetes Engine (GKE).

---

## Part 1: Deep Analysis of `gitops-aks-baseline`

The reference repository uses an advanced **ArgoCD ApplicationSet (App-of-Apps) + Kustomize + Helm** architecture. 

### 1. Directory Structure
* **`bootstrap/`**: The core controller. Contains ArgoCD ApplicationSets tailored per environment (e.g., `mgt-k01`).
* **`apps/`**: The core infrastructure services (e.g., `external-secrets`, `cert-manager`). Each app contains:
  * `base/`: Universal configurations (Namespace, RBAC, common Helm `values-common.yaml`).
  * `envs/<env-name>/`: Environment-specific overrides and the main `kustomization.yaml`.
* **`charts/`**: Local Helm chart storage to ensure immutable and fast deployments independent of external Helm repository availability.

### 2. The ApplicationSet Pattern (Git Generator)
Instead of manually defining an ArgoCD Application for every single tool, the `ApplicationSet` uses a **Git Directory Generator**. 
It scans the repository for a specific path pattern (e.g., `apps/*/envs/mgt-k01`). For every matching directory, it automatically provisions an ArgoCD Application, parsing the app name and namespace directly from the folder structure.

### 3. Kustomize Helm Inflation
Instead of writing native Kubernetes YAML or forking Helm charts, the repository uses Kustomize's native Helm integration (`helmGlobals` and `helmCharts` fields in `kustomization.yaml`). This allows merging local `base/values-common.yaml` and environment-specific `values-additional.yaml` seamlessly into the Helm chart before deployment.

### 4. Advanced `ignoreDifferences`
The ApplicationSet defines a massive `ignoreDifferences` block. In Kubernetes, mutating webhooks (like those injected by Istio or Cert-Manager) automatically modify live resources. If ArgoCD doesn't ignore these dynamic changes (like `caBundle` injections or dynamic `checksum` annotations), it gets stuck in a constant "OutOfSync" loop.

---

## Part 2: Step-by-Step Implementation Plan for GCP (GKE)

We will replicate this exact architecture, optimized for GCP.

### Step 1: Initialize the Directory Structure
1. Create the root `gcp-bootstrap` directory.
2. Scaffold the fundamental folder layout: `bootstrap/`, `apps/`, `charts/`.

### Step 2: Create the GKE ApplicationSet (`bootstrap/`)
1. Create an environment folder for GCP, e.g., `bootstrap/gke-prod-01`.
2. Write the `gke-prod-01-appset.yaml` file.
3. Configure the Git generator to point to `apps/*/envs/gke-prod-01`.
4. Define GKE-specific `ignoreDifferences` (e.g., ignoring GKE Autopilot's automatic resource mutations or GCP Workload Identity annotations).

### Step 3: Scaffold the First Core App - External Secrets (`apps/`)
1. Create `apps/external-secrets/base/` and `apps/external-secrets/envs/gke-prod-01/`.
2. Write `kustomization.yaml` to utilize Kustomize Helm Inflation.
3. **GCP Specifics:** Configure the `values-common.yaml` to authenticate with **GCP Secret Manager** via **Workload Identity Federation** (GKE Workload Identity), which differs entirely from Azure's setup.

### Step 4: Scaffold the Second Core App - Cert-Manager (`apps/`)
1. Create the base and environment directories for `cert-manager`.
2. Set up ClusterIssuers tailored for **Google Cloud DNS** to handle ACME DNS-01 challenges, attaching the correct GCP Service Account annotations for DNS management.

### Step 5: Test and Validate Local Manifest Generation
1. Validate the structure by running:
   ```bash
   kubectl kustomize apps/external-secrets/envs/gke-prod-01 --enable-helm --load-restrictor=LoadRestrictionsNone
   ```
2. Review the generated manifests to ensure they are fully valid for GKE.

---
*Ready to proceed? Let me know and we will execute Step 1!*
