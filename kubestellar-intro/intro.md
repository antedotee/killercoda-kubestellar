# Welcome to KubeStellar!

## What is KubeStellar?

**KubeStellar** is a CNCF Sandbox project that simplifies multi-cluster Kubernetes configuration management. Unlike other solutions, KubeStellar lets you work with **pure Kubernetes objects**—no wrapping, no bundling, no new APIs to learn.

## Why KubeStellar?

### 🚀 **Simpler Than Alternatives**

**vs. Open Cluster Management (OCM):**
- OCM requires wrapping workloads in `ManifestWork` objects
- KubeStellar uses native Kubernetes objects directly
- Same OCM transport, simpler developer experience

**vs. ArgoCD:**
- ArgoCD requires `Application` CRDs and GitOps workflows
- KubeStellar works with standard `kubectl` and `helm` commands
- No Git repository required for basic deployments

**vs. Fleet:**
- Fleet requires wrapping in `GitRepo` and `Bundle` objects
- KubeStellar uses familiar Kubernetes label selectors
- More flexible cluster selection with binding policies

### ✨ **Key Benefits**

1. **Pure Kubernetes**: Deploy standard objects (Deployments, Services, ConfigMaps, etc.) without modification
2. **Simple Policies**: Use label selectors to define where workloads go—just like Kubernetes selectors you already know
3. **Works Everywhere**: Compatible with kubectl, Helm, ArgoCD, and any Kubernetes-native tool
4. **Dynamic**: Add/remove clusters and policies without downtime
5. **Production Ready**: Built on proven OCM transport layer with enterprise-grade reliability

## What You'll Learn

In this tutorial, you'll:
1. **Install KubeStellar Core** - Set up the control planes (ITS and WDS)
2. **Register Clusters** - Connect multiple Kubernetes clusters to KubeStellar
3. **Deploy Multi-Cluster** - Use a simple binding policy to deploy workloads across clusters

## Prerequisites

This environment comes with:
- Kubernetes cluster (1 node with taint removed, ready to schedule workloads)
- kubectl
- Docker
- curl

**Note**: KubeStellar control planes can take 5-10 minutes to become ready. This is normal and depends on resource availability. The environment has been optimized for faster startup.

We'll install KubeStellar components during the tutorial.

**Ready to simplify your multi-cluster journey? Let's get started!** 🎯