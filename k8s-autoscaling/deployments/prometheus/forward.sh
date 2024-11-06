sudo ufw allow 30001
kubectl port-forward svc/prometheus-server -n monitoring --address 0.0.0.0 30001:80
