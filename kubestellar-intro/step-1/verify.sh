#!/bin/bash
set -e

echo "Verifying prerequisites..."

# Check kflex
if ! command -v kflex &> /dev/null; then
    echo "❌ kflex not found in PATH"
    exit 1
fi

# Verify kflex is executable and not corrupted
if ! kflex version &> /dev/null; then
    echo "❌ kflex binary is corrupted or not executable"
    file $(which kflex) || echo "Cannot determine file type"
    exit 1
fi

# Check clusteradm
if ! command -v clusteradm &> /dev/null; then
    echo "❌ clusteradm not found"
    exit 1
fi

# Check helm
if ! command -v helm &> /dev/null; then
    echo "❌ helm not found"
    exit 1
fi

# Check kubectl
if ! kubectl version --client &> /dev/null; then
    echo "❌ kubectl not working"
    exit 1
fi

echo "✅ All prerequisites installed and working!"