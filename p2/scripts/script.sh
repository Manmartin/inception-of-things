export K3S_TOKEN=1234; wget -qO- https://get.k3s.io | INSTALL_K3S_EXEC=--flannel-iface=eth1 sh - ;
kubectl create configmap app1 --from-file /vagrant_shared/app1/index.html
kubectl create configmap app2 --from-file /vagrant_shared/app2/index.html
kubectl create configmap app3 --from-file /vagrant_shared/app3/index.html
kubectl apply -f /vagrant_shared/app.yml