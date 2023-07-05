#!/bin/bash

export EXTERNALIP=$(kubectl get svc --all-namespaces -o jsonpath='{range.items[?(@.status.loadBalancer.ingress)]}{.status.loadBalancer.ingress[*].ip}')

helm registry login --username=$1 --password=$2 harbor.$EXTERNALIP.nip.io

helm push hipster-shop-0.1.0.tgz oci://harbor.$EXTERNALIP.nip.io/library

helm push frontend-0.1.0.tgz oci://harbor.$EXTERNALIP.nip.io/library