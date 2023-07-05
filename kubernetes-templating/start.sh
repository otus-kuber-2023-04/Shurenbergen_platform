#!/bin/bash

echo "###############################" && \
echo "Install nginx-ingress from helm" && \
echo "###############################" && \
kubectl create ns nginx-ingress && \
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
helm repo update && \
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace=nginx-ingress && \
--version=4.7.0 && \

export EXTERNALIP=$(kubectl get svc --all-namespaces -o jsonpath='{range.items[?(@.status.loadBalancer.ingress)]}\
{.status.loadBalancer.ingress[*].ip}') && \

echo "Это ваш внешний айпи адрес проекта" && \
echo $EXTERNALIP
echo "автозамена по всем файлам на ваш адрес" && \

envsubst < chartmuseum/values_template.yaml > chartmuseum/values.yaml && \
envsubst < harbor/values_template.yaml > harbor/values.yaml && \
envsubst < cert-manager/issuer_template.yaml > cert-manager/issuer.yaml && \
envsubst < frontend/values_template.yaml > frontend/values.yaml && \

echo "##############################" && \
echo "Install cert-manager from helm" && \
echo "##############################" && \
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.2/cert-manager.crds.yaml && \
helm repo add jetstack https://charts.jetstack.io && \
kubectl create ns cert-manager && \
helm upgrade --install cert-manager jetstack/cert-manager --wait \
--namespace=cert-manager \
--version=1.12.2 && \
kubectl apply -f cert-manager/issuer.yaml && \

echo "#############################" && \
echo "Install chartmuseum from helm" && \
echo "#############################" && \

kubectl create ns chartmuseum && \
helm repo add chartmuseum https://chartmuseum.github.io/charts && \
helm upgrade --install chartmuseum chartmuseum/chartmuseum --wait \
--namespace=chartmuseum \
--version=3.10.1 \
-f chartmuseum/values.yaml && \

echo "########################" && \
echo "Install Harbor from helm" && \
echo "########################" && \

kubectl create ns harbor && \
helm repo add harbor https://helm.goharbor.io && \
helm upgrade --install harbor harbor/harbor --wait \
--namespace=harbor \
--version=1.12.2 \
-f harbor/values.yaml && \

echo "########################" && \
echo "Install hipster-shop from helm" && \
echo "########################" && \

helm upgrade --install hipster-shop hipster-shop --namespace hipster-shop && \
helm upgrade --install hipster-shop hipster-shop --namespace hipster-shop --set frontend.service.nodePort=31234 && \

echo "###########################################" && \
echo "Package, Add, and Push helms repo to Harbor" && \
echo "###########################################" && \

helm package hipster-shop && helm package frontend && \
chmod +x repo2.sh && \
./repo2.sh admin Harbor12345 && \

echo "###########################################" && \
echo "Kubecfg" && \
echo "###########################################" && \

kubecfg show kubecfg/services.jsonnet && \
kubecfg update kubecfg/services.jsonnet --namespace hipster-shop && \

echo "###########################################" && \
echo "Kustomize" && \
echo "###########################################" && \

kubectl apply -k kustomize/overrides/dev/ && \
kubectl apply -k kustomize/overrides/prod/