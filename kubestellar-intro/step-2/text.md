# Step 2: Set Up KubeStellar

We'll install KubeStellar using the Core Helm chart, which includes KubeFlex operator automatically.

## Install KubeStellar Core

The Core Helm chart installs both KubeFlex operator and KubeStellar components in one step:

```bash
export KUBESTELLAR_VERSION=0.29.0

helm upgrade --install ks-core oci://ghcr.io/kubestellar/kubestellar/core-chart \
    --version "$KUBESTELLAR_VERSION" \
    --set-json ITSes='[{"name":"its1"}]' \
    --set-json WDSes='[{"name":"wds1"}]' \
    --set verbosity.default=5
```{{exec}}

**Note**: We're using the Core Helm chart instead of `kflex init` to avoid version detection issues. The chart automatically installs the KubeFlex operator.

## Verify Installation

Check that the operator is running:

```bash
kubectl get pods -n kubeflex-system
kubectl get controlplanes
```{{exec}}

## Wait for Control Planes to Be Created

Wait for control planes to be created. This typically takes 1-2 minutes:

```bash
echo "Waiting for control planes to be created..."
timeout 300 bash -c 'until kubectl get controlplane its1 -o jsonpath="{.status.conditions[?(@.type==\"Synced\")].status}" 2>/dev/null | grep -q True; do echo "Waiting for its1 to sync..."; sleep 5; done'
timeout 300 bash -c 'until kubectl get controlplane wds1 -o jsonpath="{.status.conditions[?(@.type==\"Synced\")].status}" 2>/dev/null | grep -q True; do echo "Waiting for wds1 to sync..."; sleep 5; done'

echo "✅ Control planes are synced!"
```{{exec}}

## Wait for Control Planes to Be Ready

Now wait for them to be ready (API servers available):

```bash
echo "Waiting for control planes to be ready..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/wds1 \
    --for condition=Ready \
    --timeout=600s || {
    echo "⚠️  wds1 not ready, checking status..."
    kubectl describe controlplane wds1 | tail -20
    exit 1
}

kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 \
    --for condition=Ready \
    --timeout=600s || {
    echo "⚠️  its1 not ready, checking status..."
    kubectl describe controlplane its1 | tail -20
    exit 1
}

echo "✅ Control planes are ready!"
```{{exec}}

## Get Kubeconfig Contexts

Now that the control planes are ready, we can get their contexts:

```bash
kflex ctx --set-current-for-hosting
kflex ctx --overwrite-existing-context wds1
kflex ctx --overwrite-existing-context its1
```{{exec}}

## Wait for ITS Initialization

The ITS needs to be initialized as an OCM hub. This may take 2-3 minutes:

```bash
echo "Waiting for ITS initialization..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 \
    --for 'jsonpath={.status.postCreateHooks.its-hub-init}=true' \
    --timeout=600s || {
    echo "⚠️  ITS hub init not complete, checking jobs..."
    kubectl get jobs -n its1-system
    exit 1
}

kubectl wait -n its1-system job.batch/its-hub-init \
    --for condition=Complete \
    --timeout=600s

kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 \
    --for 'jsonpath={.status.postCreateHooks.install-status-addon}=true' \
    --timeout=600s

kubectl wait -n its1-system job.batch/install-status-addon \
    --for condition=Complete \
    --timeout=600s

echo "✅ ITS initialization complete!"
```{{exec}}

## Verify Setup

```bash
kubectl --context its1 get managedclusters
kubectl --context wds1 get bindingpolicies
```{{exec}}

Great! KubeStellar is now set up and ready to use.