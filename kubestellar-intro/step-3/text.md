# Step 3: Create Workload Execution Clusters

We'll create two kind clusters to serve as workload execution clusters (WECs).

## Create Two Kind Clusters

```bash
kind create cluster --name cluster1
kind create cluster --name cluster2
kubectl config rename-context kind-cluster1 cluster1
kubectl config rename-context kind-cluster2 cluster2
```{{exec}}

## Register Clusters with OCM Hub

Get the join token and register both clusters:

```bash
# Register cluster1
TOKEN=$(clusteradm --context its1 get token 2>/dev/null | grep '^clusteradm join' | head -1)
if [ -z "$TOKEN" ]; then
    echo "Error: Could not get join token"
    exit 1
fi

echo "$TOKEN" | sed "s/<cluster_name>/cluster1/" | awk '{print $0 " --context cluster1 --singleton --force-internal-endpoint-lookup"}' | sh

# Register cluster2
echo "$TOKEN" | sed "s/<cluster_name>/cluster2/" | awk '{print $0 " --context cluster2 --singleton --force-internal-endpoint-lookup"}' | sh
```{{exec}}

## Wait for Certificate Signing Requests

Wait for CSRs to appear, then approve them:

```bash
echo "Waiting for CSRs to appear..."
timeout 120 bash -c 'until [ $(kubectl --context its1 get csr 2>/dev/null | grep -c "cluster1\|cluster2") -ge 2 ]; do echo "Waiting for CSRs..."; sleep 5; done'

# Approve CSRs
clusteradm --context its1 accept --clusters cluster1
clusteradm --context its1 accept --clusters cluster2

echo "✅ Clusters registered!"
```{{exec}}

## Label the Clusters

Label clusters for selection by binding policies:

```bash
kubectl --context its1 label managedcluster cluster1 location-group=edge name=cluster1 --overwrite
kubectl --context its1 label managedcluster cluster2 location-group=edge name=cluster2 --overwrite
```{{exec}}

## Verify Cluster Registration

```bash
kubectl --context its1 get managedclusters
kubectl --context its1 get managedclusters -l location-group=edge
```{{exec}}

Perfect! Both clusters are now registered and labeled.