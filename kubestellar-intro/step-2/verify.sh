#!/bin/bash
set -e

echo "Verifying KubeStellar setup..."

# Check ITS context exists and works
if ! kubectl --context its1 get managedclusters &> /dev/null; then
    echo "❌ ITS context not working"
    exit 1
fi

# Check WDS context exists and works
if ! kubectl --context wds1 get bindingpolicies &> /dev/null; then
    echo "❌ WDS context not working"
    exit 1
fi

# Check control planes are ready
WDS1_READY=$(kubectl get controlplane wds1 -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "False")
ITS1_READY=$(kubectl get controlplane its1 -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "False")

if [ "$WDS1_READY" != "True" ]; then
    echo "❌ wds1 control plane not ready"
    exit 1
fi

if [ "$ITS1_READY" != "True" ]; then
    echo "❌ its1 control plane not ready"
    exit 1
fi

echo "✅ KubeStellar setup complete!"