#!/bin/bash
set -e

echo "Verifying KubeStellar setup..."

# Check ITS context exists
if ! kubectl --context its1 get managedclusters &> /dev/null; then
    echo "❌ ITS context not working"
    exit 1
fi

# Check WDS context exists
if ! kubectl --context wds1 get bindingpolicies &> /dev/null; then
    echo "❌ WDS context not working"
    exit 1
fi

# Check ITS is ready
if ! kubectl --context its1 get managedclusters &> /dev/null; then
    echo "❌ ITS not ready"
    exit 1
fi

echo "✅ KubeStellar setup complete!"