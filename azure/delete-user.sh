#!/bin/bash

USERNAME=$1

kubectl delete namespace/cicd-$USERNAME
kubectl delete namespace/dev-$USERNAME
kubectl delete namespace/stage-$USERNAME
kubectl delete namespace/prod-$USERNAME

kubectl delete clusterrolebinding/$USERNAME-view-cluster
kubectl delete -n serviceaccount/$USERNAME default 
