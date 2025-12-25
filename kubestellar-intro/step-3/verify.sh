#!/bin/bash
set -e

echo "Verifying cluster registration..."

# Check clusters are registered
CLUSTER_COUNT=$(kubectl --context its1 get managedclusters -l location-group=edge --no-headers | wc -l)

if [ "$CLUSTER_COUNT" -lt 2 ]; then
    echo "❌ Expected 2 clusters, found $CLUSTER_COUNT"
    exit 1
fi

# Check clusters are labeled
if ! kubectl --context its1 get managedclusters -l location-group=edge &> /dev/null; then
    echo "❌ Clusters not properly labeled"
    exit 1
fi

echo "✅ Clusters registered and labeled!"