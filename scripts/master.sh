#!/bin/bash

set -euxo pipefail

#set environment variables
MASTER_IP="10.0.0.10"
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"
CRI_SOCKET="unix:///var/run/cri-dockerd.sock"

sudo kubeadm config images pull --cri-socket $CRI_SOCKET

echo "Preflight Check Passed: Downloaded All Required Images"

sudo kubeadm init --pod-network-cidr=$POD_CIDR --cri-socket $CRI_SOCKET --apiserver-advertise-address=$MASTER_IP

#after successful kubeadm join

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Install CNI plugin (Calico)

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml

#wait for all pods to run

#save join command output

kubeadm token create --print-join-command > token

#after worker node joined, label the worker node role
#kubectl label node k8s-worker-01 node-role.kubernetes.io/worker=worker
