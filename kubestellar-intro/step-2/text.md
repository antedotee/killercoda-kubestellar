# Step 2: Set Up KubeStellar

Following the [official KubeStellar getting started guide](https://kubestellar.io/docs/direct/get-started/).

## Set the Version

```bash
export kubestellar_version=0.29.0
```{{exec}}

## Install KubeStellar Core using Helm Chart

The Core Helm chart installs both KubeFlex operator and KubeStellar components:

```bash
helm upgrade --install ks-core oci://ghcr.io/kubestellar/kubestellar/core-chart \
    --version "$kubestellar_version" \
    --set-json ITSes='[{"name":"its1"}]' \
    --set-json WDSes='[{"name":"wds1"}]' \
    --set verbosity.default=5
```{{exec}}

## Get Kubeconfig Contexts

After the Helm chart installs, get the contexts for the control planes:

```bash
kubectl config use-context controlplane
kflex ctx --set-current-for-hosting
kflex ctx --overwrite-existing-context wds1
kflex ctx --overwrite-existing-context its1
```{{exec}}

## Wait for Control Planes to Be Ready

Wait for the control planes to sync and become ready:

```bash
echo "Waiting for control planes to sync..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/wds1 --for condition=Synced --timeout=300s
kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 --for condition=Synced --timeout=300s

echo "Waiting for control planes to be ready..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/wds1 --for condition=Ready --timeout=600s
kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 --for condition=Ready --timeout=600s
```{{exec}}

## Wait for ITS Initialization

The ITS needs to be initialized as an OCM hub:

```bash
echo "Waiting for ITS hub initialization..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 --for 'jsonpath={.status.postCreateHooks.its-hub-init}=true' --timeout=600s
kubectl wait -n its1-system job.batch/its-hub-init --for condition=Complete --timeout=600s

echo "Waiting for status addon installation..."
kubectl wait controlplane.tenancy.kflex.kubestellar.org/its1 --for 'jsonpath={.status.postCreateHooks.install-status-addon}=true' --timeout=600s
kubectl wait -n its1-system job.batch/install-status-addon --for condition=Complete --timeout=600s
```{{exec}}

## Verify Setup

```bash
kubectl --context its1 get managedclusters
kubectl --context wds1 get bindingpolicies
```{{exec}}

Great! KubeStellar is now set up and ready to use.