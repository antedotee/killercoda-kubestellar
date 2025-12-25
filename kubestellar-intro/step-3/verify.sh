#!/bin/bash
set -e

echo "Verifying cluster registration..."

# Check clusters are registered
CLUSTER_COUNT=$(kubectl --context its1 get managedclusters -l location-group=edge --no-headers 2>/dev/null | wc -l)

if [ "$CLUSTER_COUNT" -lt 2 ]; then
    echo "❌ Expected 2 clusters, found $CLUSTER_COUNT"
    kubectl --context its1 get managedclusters
    exit 1
fi

# Check clusters are labeled
if ! kubectl --context its1 get managedclusters -l location-group=edge &> /dev/null; then
    echo "❌ Clusters not properly labeled"
    exit 1
fi

# Check clusters are accepted (not pending)
PENDING=$(kubectl --context its1 get managedclusters -l location-group=edge -o jsonpath='{.items[*].status.conditions[?(@.type=="HubAcceptedManagedCluster")].status}' 2>/dev/null | grep -c False || echo "0")

if [ "$PENDING" -gt 0 ]; then
    echo "⚠️  Some clusters are still pending acceptance"
    kubectl --context its1 get managedclusters -l location-group=edge
fi

echo "✅ Clusters registered and labeled!"