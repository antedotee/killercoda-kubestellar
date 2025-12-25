# Step 2: Set Up KubeStellar

Now we'll initialize KubeFlex and create the core KubeStellar components.

## Initialize KubeFlex

First, let's initialize KubeFlex on the current cluster:

```bash
kflex init
```{{exec}}

Wait for KubeFlex to be ready:

```bash
kubectl wait --for=condition=Ready controlplane.tenancy.kflex.kubestellar.org/kubeflex --timeout=300s
```{{exec}}

## Install KubeStellar Core

Now install KubeStellar using the Helm chart:

```bash
export KUBESTELLAR_VERSION=0.29.0
helm upgrade --install ks-core oci://ghcr.io/kubestellar/kubestellar/core-chart \
    --version "$KUBESTELLAR_VERSION" \
    --set-json ITSes='[{"name":"its1"}]' \
    --set-json WDSes='[{"name":"wds1"}]' \
    --set verbosity.default=5
```{{exec}}

## Get Kubeconfig Contexts

Set up contexts for accessing ITS and WDS:

```bash
kflex ctx --set-current-for-hosting
kflex ctx --overwrite-existing-context wds1
kflex ctx --overwrite-existing-context its1
```{{exec}}

## Wait for ITS Initialization

The ITS needs to be initialized as an OCM hub:

```bash
kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 \
    --for 'jsonpath={.status.postCreateHooks.its-hub-init}=true' \
    --timeout=300s

kubectl wait -n its1-system job.batch/its-hub-init \
    --for condition=Complete \
    --timeout=300s

kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 \
    --for 'jsonpath={.status.postCreateHooks.install-status-addon}=true' \
    --timeout=300s
```{{exec}}

Great! KubeStellar is now set up. Let's verify:

```bash
kubectl --context its1 get managedclusters
kubectl --context wds1 get bindingpolicies
```{{exec}}