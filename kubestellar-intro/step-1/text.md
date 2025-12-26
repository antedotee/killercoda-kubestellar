# Step 1: Install Prerequisites

KubeStellar requires several CLI tools. Let's install them following the official documentation.

## Install KubeFlex CLI (kflex)

Installing kflex version 0.9.0 to avoid breaking changes:

```bash
curl -Lf --max-time 30 -o kflex.tar.gz "https://github.com/kubestellar/kubeflex/releases/download/v0.9.0/kubeflex_0.9.0_linux_amd64.tar.gz" || curl -Lf --max-time 30 -o kflex.tar.gz "https://github.com/kubestellar/kubeflex/releases/download/v0.9.0/kubeflex-v0.9.0-linux-amd64.tar.gz"
tar xzf kflex.tar.gz
sudo install -o root -g root -m 0755 bin/kflex /usr/local/bin/kflex
rm -rf bin kflex.tar.gz
kflex version
```{{exec}}

## Install OCM CLI (clusteradm)

Following the [official KubeStellar prerequisites](https://kubestellar.io/docs/direct/pre-reqs/):

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