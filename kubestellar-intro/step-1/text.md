# Step 1: Install Prerequisites

KubeStellar requires several CLI tools. Let's install them:

## Install KubeFlex CLI (kflex)

Use the official installation script which handles architecture detection:

```bash
# Remove any existing corrupted binary
sudo rm -f /usr/local/bin/kflex 2>/dev/null || true

# Install using official script
curl -sSL https://raw.githubusercontent.com/kubestellar/kubeflex/main/scripts/install-kubeflex.sh | bash -s -- --ensure-folder /tmp/kubeflex --strip-bin
sudo mv /tmp/kubeflex/kflex /usr/local/bin/
sudo chmod +x /usr/local/bin/kflex
rm -rf /tmp/kubeflex

# Verify installation
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