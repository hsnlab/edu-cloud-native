kubectl run -i --tty load-generator --rm --image=docker.io/fortio/fortio --restart=Never -- load -keepalive=false -allow-initial-errors -qps 0 -t 300s -connection-reuse 0:0 -c 4 -json - http://demo-webserver:8080 | grep "All done"