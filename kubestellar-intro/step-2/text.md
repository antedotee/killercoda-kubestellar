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

## Wait for Control Planes to Be Created

Wait for the Helm chart to create the control plane resources:

```bash
echo "Waiting for control planes to be created..."
timeout 180 bash -c 'until kubectl get controlplane wds1 &>/dev/null && kubectl get controlplane its1 &>/dev/null; do echo "Waiting for control planes..."; sleep 5; done'
kubectl get controlplanes
```{{exec}}

## Check KubeFlex Operator Status

Before proceeding, verify the KubeFlex operator is running properly:

```bash
echo "Checking KubeFlex operator..."
kubectl get pods -n kubeflex-system
kubectl get deployment -n kubeflex-system
```{{exec}}

## Monitor Control Plane Progress

Check the status and watch for progress. Control planes can take several minutes to become ready:

```bash
echo "Current control plane status:"
kubectl get controlplanes -o wide

echo "Checking control plane details..."
kubectl describe controlplane wds1 | grep -A 10 "Status:"
kubectl describe controlplane its1 | grep -A 10 "Status:"

echo "Checking vcluster StatefulSet for its1..."
kubectl get statefulset -n its1-system 2>/dev/null || echo "StatefulSet not created yet"
kubectl get pods -n its1-system 2>/dev/null || echo "No pods yet"

echo "Waiting for vcluster secret to be created (this is normal for vcluster type)..."
timeout 300 bash -c 'until kubectl get secret vc-vcluster -n its1-system &>/dev/null 2>&1; do echo "Waiting for vcluster secret..."; sleep 5; done' || echo "Secret not ready yet, will retry"
```{{exec}}

## Wait for Control Planes to Be Ready

Wait for the API servers to be ready. This can take 5-10 minutes depending on resources:

```bash
echo "Waiting for wds1 to be ready (this may take 5-10 minutes)..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/wds1 --for condition=Ready --timeout=900s || {
    echo "⚠️  wds1 not ready yet. Checking pod status..."
    kubectl get pods -n wds1-system
    kubectl describe controlplane wds1 | tail -30
}

echo "Waiting for vcluster StatefulSet to be ready (this creates the secret)..."
# Wait for StatefulSet to exist and be ready
timeout 300 bash -c 'until kubectl get statefulset vcluster -n its1-system &>/dev/null 2>&1; do echo "Waiting for StatefulSet..."; sleep 5; done'
kubectl wait statefulset/vcluster -n its1-system --for condition=ready --timeout=600s || {
    echo "⚠️  StatefulSet not ready. Checking status..."
    kubectl get statefulset -n its1-system
    kubectl get pods -n its1-system
}

echo "Waiting for vcluster secret to be created..."
timeout 180 bash -c 'until kubectl get secret vc-vcluster -n its1-system &>/dev/null 2>&1; do echo "Waiting for secret vc-vcluster..."; sleep 5; done' || {
    echo "⚠️  Secret not created yet. Checking pods..."
    kubectl get pods -n its1-system
    kubectl logs -n its1-system -l app=vcluster --tail=20 2>/dev/null || echo "No logs yet"
}

echo "Now waiting for its1 to sync (after secret exists)..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 --for condition=Synced --timeout=300s || {
    echo "⚠️  its1 sync still failing. Final diagnostics..."
    kubectl get secret vc-vcluster -n its1-system || echo "Secret still missing"
    kubectl describe controlplane its1 | tail -30
}

echo "Waiting for its1 to be ready (this may take 5-10 minutes)..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 --for condition=Ready --timeout=900s || {
    echo "⚠️  its1 not ready yet. Checking pod status..."
    kubectl get pods -n its1-system -o wide
    kubectl describe controlplane its1 | tail -30
    echo "=== Checking if secret exists ==="
    kubectl get secret vc-vcluster -n its1-system || echo "Secret still not found"
    echo "=== Checking node status ==="
    kubectl get nodes
}
```{{exec}}

## Get Kubeconfig Contexts

Now that control planes are ready, set up contexts to access them:

```bash
kubectl config use-context controlplane
kflex ctx --set-current-for-hosting
kflex ctx --overwrite-existing-context wds1
kflex ctx --overwrite-existing-context its1
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