# Step 1: Install Prerequisites

KubeStellar requires several CLI tools. Let's install them following the official documentation.

## Install KubeFlex CLI (kflex)

Installing kflex using the official installation script:

```bash
sudo su <<EOF
bash <(curl -s https://raw.githubusercontent.com/kubestellar/kubeflex/main/scripts/install-kubeflex.sh) --ensure-folder /usr/local/bin --strip-bin
EOF
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

## Install kind

kind is needed to create workload execution clusters:

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version
```{{exec}}

## Verify kubectl

```bash
kubectl version --client
kubectl get nodes
```{{exec}}

Once all tools are installed, proceed to the next step!