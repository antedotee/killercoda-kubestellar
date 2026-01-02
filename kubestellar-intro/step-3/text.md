# Step 3: Create Workload Execution Clusters

Following the [official getting started guide](https://kubestellar.io/docs/direct/get-started/#create-and-register-two-workload-execution-clusters).

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
flags="--force-internal-endpoint-lookup"
clusters=(cluster1 cluster2)
for cluster in "${clusters[@]}"; do
   clusteradm --context its1 get token | grep '^clusteradm join' | sed "s/<cluster_name>/${cluster}/" | awk '{print $0 " --context '${cluster}' --singleton '${flags}'"}' | sh
done
```{{exec}}

## Wait for Certificate Signing Requests

Wait for CSRs to appear, then approve them:

```bash
echo "Waiting for CSRs to appear..."
while true; do
    kubectl --context its1 get csr
    if [ $(kubectl --context its1 get csr 2>/dev/null | grep -c "Pending") -ge 2 ]; then
        echo "Both CSRs found."
        break
    fi
    echo "Waiting for CSRs to appear..."
    sleep 10
done

# Approve CSRs
clusteradm --context its1 accept --clusters cluster1
clusteradm --context its1 accept --clusters cluster2
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