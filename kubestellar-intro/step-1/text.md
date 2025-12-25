# Step 1: Install Prerequisites

KubeStellar requires several CLI tools. Let's install them:

## Install KubeFlex CLI (kflex)

We'll install kflex directly from GitHub releases:
h
# Remove any existing corrupted binary
sudo rm -f /usr/local/bin/kflex 2>/dev/null || true

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Get latest version
echo "Fetching latest kflex version..."
VERSION=$(curl -s https://api.github.com/repos/kubestellar/kubeflex/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
echo "Installing kflex ${VERSION} for ${ARCH}..."

# Download and extract
curl -L -f -o kubeflex.tar.gz "https://github.com/kubestellar/kubeflex/releases/download/${VERSION}/kubeflex_${VERSION//v}_linux_${ARCH}.tar.gz"
tar -xzf kubeflex.tar.gz

# Install to system PATH
sudo mv bin/kflex /usr/local/bin/
sudo chmod +x /usr/local/bin/kflex

# Cleanup
rm -rf bin kubeflex.tar.gz

# Verify installation
kflex version
```{{exec}}

## Install OCM CLI (clusteradm)

bash <(curl -L https://raw.githubusercontent.com/open-cluster-management-io/clusteradm/main/install.sh) 0.10.1
clusteradm version
```{{exec}}

## Install Helm
sh
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```{{exec}}

## Verify kubectl

kubectl version --client
kubectl get nodes
```{{exec}}

Once all tools are installed, proceed to the next step!Changes:
- Removed the script method and fallback logic
- Uses direct manual installation
- Clearer error handling
- Simpler flow

Copy the entire block above into your `step1/text.md` file. This should execute successfully in Killercoda.