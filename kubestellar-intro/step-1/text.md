# Welcome to KubeStellar!

KubeStellar simplifies multi-cluster Kubernetes configuration management. 
Instead of managing each cluster individually, you define workloads once and 
use binding policies to deploy them across multiple clusters.

## What You'll Learn:
- How to set up KubeStellar with KubeFlex
- How to create and register workload execution clusters
- How to deploy workloads across multiple clusters using BindingPolicies
- How KubeStellar works with kubectl, Helm, and ArgoCD

## Prerequisites:
This environment comes with:
- Kubernetes cluster (2 nodes)
- kubectl
- Docker
- curl

We'll install KubeStellar components during the tutorial.

Let's get started!
```

---

## File: kubestellar-intro/step1/text.md

```markdown
# Step 1: Install Prerequisites

KubeStellar requires several CLI tools. Let's install them:

## Install KubeFlex CLI (kflex)

Try the official script first, with fallback to manual installation:

```bash
# Remove any existing corrupted binary
sudo rm -f /usr/local/bin/kflex 2>/dev/null || true

# Method 1: Official script (preferred)
echo "Installing kflex using official script..."
if curl -sSL https://raw.githubusercontent.com/kubestellar/kubeflex/main/scripts/install-kubeflex.sh | bash -s -- --ensure-folder /tmp/kubeflex --strip-bin --verbose; then
    if [ -f /tmp/kubeflex/kflex ]; then
        sudo mv /tmp/kubeflex/kflex /usr/local/bin/
        sudo chmod +x /usr/local/bin/kflex
        rm -rf /tmp/kubeflex
        echo "✅ kflex installed via script"
    else
        echo "⚠️  Script completed but binary not found, trying manual install..."
        # Fall through to manual install
    fi
else
    echo "⚠️  Script failed, trying manual install..."
fi

# Method 2: Manual installation (fallback if script fails)
if ! command -v kflex &> /dev/null; then
    echo "Installing kflex manually..."
    
    ARCH=$(uname -m)
    [ "$ARCH" = "x86_64" ] && ARCH="amd64" || ARCH="arm64"
    
    VERSION=$(curl -s https://api.github.com/repos/kubestellar/kubeflex/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "Downloading kflex ${VERSION} for ${ARCH}..."
    
    curl -L -f -o kubeflex.tar.gz "https://github.com/kubestellar/kubeflex/releases/download/${VERSION}/kubeflex_${VERSION//v}_linux_${ARCH}.tar.gz"
    tar -xzf kubeflex.tar.gz
    sudo mv bin/kflex /usr/local/bin/
    sudo chmod +x /usr/local/bin/kflex
    rm -rf bin kubeflex.tar.gz
    
    echo "✅ kflex installed manually"
fi

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