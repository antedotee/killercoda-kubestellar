# Step 4: Deploy Multi-Cluster Workload

Now for the exciting part! We'll deploy an nginx application to **both clusters** using a single BindingPolicy.

## Create BindingPolicy

A BindingPolicy defines:
- **WHERE**: Which clusters (using label selectors)
- **WHAT**: Which workloads (using label selectors)

```bash
kubectl --context wds1 apply -f - <<EOF
apiVersion: control.kubestellar.io/v1alpha1
kind: BindingPolicy
metadata:
  name: nginx-bpolicy
spec:
  clusterSelectors:
  - matchLabels:
      location-group: edge
  downsync:
  - objectSelectors:
    - matchLabels:
        app.kubernetes.io/name: nginx
EOF
```{{exec}}

## Deploy the Application

Now deploy nginx to the WDS. KubeStellar will automatically propagate it to both clusters!

```bash
kubectl --context wds1 apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app.kubernetes.io/name: nginx
  name: nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: nginx
  labels:
    app.kubernetes.io/name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: public.ecr.aws/nginx/nginx:latest
        ports:
        - containerPort: 80
EOF
```{{exec}}

## Verify Multi-Cluster Deployment

Check that nginx is deployed in **both** clusters:

```bash
echo "=== Checking cluster1 ==="
kubectl --context cluster1 get deployments -n nginx

echo "=== Checking cluster2 ==="
kubectl --context cluster2 get deployments -n nginx
```{{exec}}

## The Magic of KubeStellar

Notice what happened:
1. You deployed **once** to the WDS
2. KubeStellar automatically deployed to **both** clusters
3. No need to modify your Kubernetes objects
4. Works with standard kubectl commands

## Check Pod Status

```bash
kubectl --context cluster1 get pods -n nginx
kubectl --context cluster2 get pods -n nginx
```{{exec}}

## View the Binding

See how KubeStellar resolved the BindingPolicy:

```bash
kubectl --context wds1 get bindings
kubectl --context wds1 describe binding nginx-bpolicy
```{{exec}}

🎉 **Congratulations!** You've successfully deployed a workload across multiple clusters using KubeStellar!