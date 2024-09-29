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
k3d cluster create my-cluster --api-port 6443 -p 8080:80@loadbalancer -p 8888:8888@loadbalancer --agents 2
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod 777 kubectl
mv kubectl /usr/bin
kubectl create namespace argocd
kubectl create namespace dev
curl https://raw.githubusercontent.com/argoproj/argo-cd/v2.10.17/manifests/install.yaml | sed 's/\/usr\/local\/bin\/argocd-server/\/usr\/local\/bin\/argocd-server\n        - --insecure\n        - --rootpath\n        - argo-cd/' > install.yaml
kubectl apply -n argocd -f install.yaml
kubectl apply -f /vagrant_shared/ingress.yml -n argocd
wget -q https://github.com/argoproj/argo-cd/releases/download/v2.12.3/argocd-linux-amd64 -O argocd
chmod 777 argocd
mv argocd /usr/bin
export podname=$(kubectl get pods -n argocd | grep argocd-server | cut -d ' ' -f1)
echo $podname
kubectl wait  --timeout=-1s --for=jsonpath='{.status.phase}'=Running pod/$podname -n argocd
sleep 10s
argocd admin initial-password -n argocd | head -n1