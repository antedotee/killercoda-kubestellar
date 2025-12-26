# Step 1: Install Prerequisites

KubeStellar requires several CLI tools. Let's install them following the official documentation.

## Install KubeFlex CLI (kflex)

Following the [official kubeflex installation instructions](https://github.com/kubestellar/kubeflex/blob/main/docs/users.md#installation):

```bash
OS_ARCH=linux_amd64
LATEST_RELEASE_URL=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/kubestellar/kubeflex/releases/latest | jq -r '.assets[] | select(.name | test("'${OS_ARCH}'")) | .browser_download_url')
curl -LO $LATEST_RELEASE_URL
tar xzvf $(basename $LATEST_RELEASE_URL)
sudo install -o root -g root -m 0755 bin/kflex /usr/local/bin/kflex
rm -rf bin $(basename $LATEST_RELEASE_URL)
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