#!/bin/bash

USERNAME=$1

kubectl create -n default serviceaccount $USERNAME
kubectl create namespace cicd-$USERNAME
kubectl create namespace dev-$USERNAME
kubectl create namespace stage-$USERNAME
kubectl create namespace prod-$USERNAME

kubectl create clusterrolebinding $USERNAME-view-cluster --clusterrole=view --serviceaccount default:$USERNAME
kubectl create -n cicd-$USERNAME rolebinding $USERNAME-admin --clusterrole=admin --serviceaccount default:$USERNAME
kubectl create -n dev-$USERNAME rolebinding $USERNAME-admin --clusterrole=admin --serviceaccount default:$USERNAME
kubectl create -n stage-$USERNAME rolebinding $USERNAME-admin --clusterrole=admin --serviceaccount default:$USERNAME
kubectl create -n prod-$USERNAME rolebinding $USERNAME-admin --clusterrole=admin --serviceaccount default:$USERNAME


TOKEN=$(kubectl get -n default secret $(kubectl get -n default serviceaccount $USERNAME -o jsonpath='{.secrets[].name}') -o go-template='{{.data.token | base64decode}}' && echo)
CA_DATA=$(cat ~/.kube/config | grep certificate-authority-data | cut -d ':' -f 2)
API_SERVER=$(cat ~/.kube/config | grep server | cut -d ':' -f 2,3,4)

if [ ! -d users ]; then mkdir users; fi

cat << DELIMITER > ./users/$USERNAME.kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data:$CA_DATA
    server:$API_SERVER
  name: kube
contexts:
- context:
    cluster: kube
    namespace: cicd-$USERNAME
    user: $USERNAME
  name: kube
current-context: kube
kind: Config
preferences: {}
users:
- name: $USERNAME
  user:
    token: $TOKEN

DELIMITER