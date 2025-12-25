# Step 1: Install Prerequisites

KubeStellar requires several CLI tools. Let's install them:

## Install KubeFlex CLI (kflex)

```bash
curl -L https://github.com/kubestellar/kubeflex/releases/latest/download/kflex-linux-amd64 -o kflex
chmod +x kflex
sudo mv kflex /usr/local/bin/
kflex version
```{{exec}}

## Install OCM CLI (clusteradm)

```bash
bash <(curl -L https://raw.githubusercontent.com/open-cluster-management-io/clusteradm/main/install.sh) 0.10.1
clusteradm version
```{{exec}}

## Install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```{{exec}}

## Verify kubectl

```bash
kubectl version --client
kubectl get nodes
```{{exec}}

Once all tools are installed, proceed to the next step!