#kubectl create -f https://raw.githubusercontent.com/verfio/fortio-operator/master/deploy/fortio.yaml

echo "start sending requests"
kubectl run -i --tty load-generator --rm --image=docker.io/fortio/fortio --restart=Never -- load -allow-initial-errors -qps $1 -t 0 -connection-reuse 0:0 -c 32 -json - http://demo-webserver:8080
