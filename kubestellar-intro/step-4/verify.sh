#!/bin/bash
set -e

echo "Verifying multi-cluster deployment..."

# Check deployment exists in cluster1
if ! kubectl --context cluster1 get deployment nginx-deployment -n nginx &> /dev/null; then
    echo "❌ Deployment not found in cluster1"
    exit 1
fi

# Check deployment exists in cluster2
if ! kubectl --context cluster2 get deployment nginx-deployment -n nginx &> /dev/null; then
    echo "❌ Deployment not found in cluster2"
    exit 1
fi

# Check binding exists
if ! kubectl --context wds1 get binding nginx-bpolicy &> /dev/null; then
    echo "❌ Binding not found"
    exit 1
fi

echo "✅ Multi-cluster deployment successful!"