# Step 2: Set Up KubeStellar Core

## What Makes KubeStellar Different?

Unlike other multi-cluster solutions that require wrapping workloads or learning new APIs, **KubeStellar lets you work with pure Kubernetes objects**. You define workloads once in their native format, then use simple label-based binding policies to deploy them across clusters. No wrapping, no bundling, no new APIs to learn—just Kubernetes as you know it.

**Key Advantages:**
- ✅ **Pure Kubernetes**: Deploy standard Kubernetes objects without modification
- ✅ **Simple Policies**: Use familiar label selectors to define where workloads go
- ✅ **No Wrapping**: Unlike OCM ManifestWorks or ArgoCD Applications, objects stay in native format
- ✅ **Works with kubectl, Helm, ArgoCD**: Use your existing tools and workflows
- ✅ **Dynamic**: Add/remove clusters and policies without downtime

## Set the Version

```bash
export kubestellar_version=0.29.0
```{{exec}}

## Install nginx Ingress with SSL Passthrough

KubeStellar requires nginx ingress with SSL passthrough enabled on the hosting cluster. Let's install and configure it using Helm with reduced CPU requests to work within resource constraints:

```bash
# Install nginx ingress with SSL passthrough enabled and reduced CPU requests
helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx --create-namespace \
    --set controller.extraArgs.enable-ssl-passthrough=true \
    --set controller.service.type=NodePort \
    --set controller.service.nodePorts.https=30443 \
    --set controller.resources.requests.cpu=50m

# Wait for ingress controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo "✅ nginx ingress with SSL passthrough is ready"
```{{exec}}

## Install KubeStellar Core using Helm Chart

The Core Helm chart installs both KubeFlex operator and KubeStellar components. This creates two control planes:
- **ITS (Inventory and Transport Space)**: Manages cluster inventory and transports workloads
- **WDS (Workload Description Space)**: Where you define workloads and binding policies

```bash
helm upgrade --install ks-core oci://ghcr.io/kubestellar/kubestellar/core-chart \
    --version "$kubestellar_version" \
    --set-json ITSes='[{"name":"its1"}]' \
    --set-json WDSes='[{"name":"wds1"}]' \
    --set verbosity.default=5
```{{exec}}

## Optimize Resource Usage for Limited CPU Environment

To work within CPU constraints, we need to aggressively reduce resource requests. The killercoda environment has limited CPU, so we'll optimize multiple components:

```bash
# Wait a moment for resources to be created
sleep 10

# Reduce PostgreSQL CPU request (from 250m to 150m)
kubectl patch statefulset postgres-postgresql -n kubeflex-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"postgresql","resources":{"requests":{"cpu":"150m"}}}]}}}}' 2>/dev/null || echo "PostgreSQL not ready yet"

# Temporarily scale down ingress-nginx to free up 50m CPU for control planes
kubectl scale deployment ingress-nginx-controller -n ingress-nginx --replicas=0 2>/dev/null || echo "Ingress not ready yet"

echo "✅ Resource optimizations applied - ingress scaled down temporarily"
```{{exec}}

## Wait for Control Planes to Be Created

Wait for the Helm chart to create the control plane resources:

```bash
echo "Waiting for control planes to be created..."
timeout 180 bash -c 'until kubectl get controlplane wds1 &>/dev/null && kubectl get controlplane its1 &>/dev/null; do echo "Waiting for control planes..."; sleep 5; done'
kubectl get controlplanes
```{{exec}}

## Reduce Resource Requests for Control Plane Pods

Before waiting for readiness, reduce CPU requests for the control plane pods to help them schedule:

```bash
# Reduce vcluster CPU request (for its1) - wait for StatefulSet to exist first
echo "Waiting for vcluster StatefulSet to be created..."
timeout 120 bash -c 'until kubectl get statefulset vcluster -n its1-system &>/dev/null 2>&1; do echo "Waiting..."; sleep 5; done' || echo "StatefulSet not created yet"

# Reduce vcluster CPU requests using strategic merge patch
# This reduces vcluster container from 200m to 100m and syncer to 50m
kubectl patch statefulset vcluster -n its1-system --type='merge' -p='{"spec":{"template":{"spec":{"containers":[{"name":"vcluster","resources":{"requests":{"cpu":"100m"}}},{"name":"syncer","resources":{"requests":{"cpu":"50m"}}}]}}}}' 2>/dev/null || echo "vcluster StatefulSet not ready for patching (will retry)"

# Reduce kube-controller-manager CPU request (for wds1) - wait for deployment to exist
echo "Waiting for kube-controller-manager deployment..."
timeout 120 bash -c 'until kubectl get deployment kube-controller-manager -n wds1-system &>/dev/null 2>&1; do echo "Waiting..."; sleep 5; done' || echo "Deployment not created yet"

# Reduce kube-controller-manager CPU request from 200m to 100m
kubectl patch deployment kube-controller-manager -n wds1-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"kube-controller-manager","resources":{"requests":{"cpu":"100m"}}}]}}}}' 2>/dev/null || echo "kube-controller-manager not ready for patching"

echo "✅ Control plane resource optimizations applied"
```{{exec}}

## Wait for Control Planes to Be Ready

Wait for the API servers to be ready. This can take 5-10 minutes depending on resources:

```bash
echo "Waiting for wds1 to be ready (this may take 5-10 minutes)..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/wds1 --for condition=Ready --timeout=900s || {
    echo "⚠️  wds1 not ready yet. Checking status..."
    kubectl get controlplanes
    kubectl get pods -n wds1-system 2>/dev/null || echo "No pods yet"
}

echo "Waiting for its1 to be ready (this may take 5-10 minutes)..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 --for condition=Ready --timeout=900s || {
    echo "⚠️  its1 not ready yet. Checking status..."
    kubectl get controlplanes
    kubectl get pods -n its1-system 2>/dev/null || echo "No pods yet"
}
```{{exec}}

## Get Kubeconfig Contexts

Now that control planes are ready, set up contexts to access them. First, ensure we're using the hosting cluster context, then create contexts for the control planes:

```bash
kubectl config use-context controlplane
kflex ctx --set-current-for-hosting
kflex ctx --overwrite-existing-context wds1
kflex ctx --overwrite-existing-context its1
```{{exec}}

## Restore Ingress Controller

Now that control planes are ready, restore the ingress controller:

```bash
# Scale ingress-nginx back up
kubectl scale deployment ingress-nginx-controller -n ingress-nginx --replicas=1

# Wait for ingress to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo "✅ Ingress controller restored"
```{{exec}}

## Wait for ITS Initialization

The ITS needs to be initialized as an OCM hub. This sets up the cluster management infrastructure:

```bash
echo "Waiting for ITS hub initialization..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 --for 'jsonpath={.status.postCreateHooks.its-hub-init}=true' --timeout=600s
kubectl wait -n its1-system job.batch/its-hub-init --for condition=Complete --timeout=600s

echo "Waiting for status addon installation..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 --for 'jsonpath={.status.postCreateHooks.install-status-addon}=true' --timeout=600s
kubectl wait -n its1-system job.batch/install-status-addon --for condition=Complete --timeout=600s
```{{exec}}

## Verify Setup

Verify that everything is working:

```bash
kubectl --context its1 get managedclusters
kubectl --context wds1 get bindingpolicies
```{{exec}}

Perfect! KubeStellar Core is now set up. The ITS is ready to manage clusters, and the WDS is ready for your workloads and binding policies.