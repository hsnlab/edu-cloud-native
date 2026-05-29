# Task Description

One way to expose a Kubernetes web service to the outside world is to create a corresponding ingress rule in the Ingress Gateway.

The task is to automate this process. Write a Kubernetes operator using the Kopf framework that maintains an ingress rule for every service that has an "auto-ingress" annotation. For the example below, it should create a ingress rule similar to "auto-ingress-my-service-http" for the service named "my-service". Note that target path in the rule is defined by the service annotation.

Moreover, the operator should always maintain a correct rule-set even if an annotation changes / disappears or a service is deleted, etc.

(We call this automation as an operator, but depending on the naming conventions sometimes the word "controller" is used instead for this simple task. See the references.)

## Example HTTP Server
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-http-server
  labels:
    app: my-server
spec:
  containers:
  - image: traefik/whoami:latest
    name: my-http-server
```

## Example Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  annotations:
    auto-ingress: "/aaa"
spec:
  selector:
    app: my-server
  ports:
    - name: http
      protocol: TCP
      port: 8080
      targetPort: 80
```

## Example Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: auto-ingress-my-service-http
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web
spec:
  rules:
    - http:
        paths:
          - path: "/aaa"
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 8080
```

## Resources and Background Literature
- [Kubernetes Documentation: Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Kopf: Kubernetes Operators Framework](https://kopf.readthedocs.io/en/stable/)

## Start the Cluster

1. Open AWS Academy login page: https://awsacademy.instructure.com/
2. Log in.
3. Start the AWS Academy Learner Lab and open the AWS Management console.
4. Click on this (CloudFormation) link: https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://vitmac12-resources.s3.amazonaws.com/k3s-multinode.template&stackName=k3s-multinode

## Install Additional Dependencies

```bash
sudo apt install python3-pip
sudo apt install python3.12-venv
python3 -m venv venv
. venv/bin/activate
pip install kopf[full-auth]
mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
```

## Testing

For testing purposes, you can run a basic HTTP server directly from CLI as well.
E.g., 
```bash
$ kubectl run my-http-server --image=traefik/whoami:latest --labels="app=my-server"
```

The (k3s) kubernetes' ingress controller listens on port 80 by default via its endpoint `web` (see annotation in Example Ingress) for incoming traffik.

To test that your ingress route is configured properly, you can use `curl`, `wget`, or any other tool and check the HTTP response. E.g.,
```bash
# From the VM in AWS
$ curl http://localhost:80/aaa
Hostname: 64e2f08a26f5
IP: 127.0.0.1
IP: ::1
IP: 172.17.0.2
RemoteAddr: 172.17.0.1:42044
GET /aaa HTTP/1.1
Host: localhost:80
User-Agent: curl/8.5.0
Accept: */*

# From outside
$ curl http://<public-IP-of-VM>:<public-VM-port>/aaa
...

```
