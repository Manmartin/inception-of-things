#!/bin/bash


# Docker (https://docs.docker.com/engine/install/debian/)

sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

## Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y curl docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# k3d (https://k3d.io/v5.6.3/#what-is-k3d)
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.0.0 bash
k3d cluster create my-cluster --api-port 6443 -p 8080:80@loadbalancer --agents 2
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod 777 kubectl
./kubectl create namespace argocd
./kubectl apply -n argocd -f /vagrant_shared/install.yaml
./kubectl apply -f /vagrant_shared/ingress.yml -n argocd
wget -q https://github.com/argoproj/argo-cd/releases/download/v2.12.3/argocd-linux-amd64 -O argocd
chmod 777 argocd