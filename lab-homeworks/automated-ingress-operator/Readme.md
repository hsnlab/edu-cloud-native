# Task Description

One way to expose a Kubernetes web service to the outside world is to create a corresponding ingress rule in the Ingress Gateway.

The task is to automate this process. Write a Kubernetes operator using the Kopf framework that maintains an ingress rule for every service that has an "auto-ingress" annotation. For the example below, it should create a ingress rule similar to "auto-ingress-my-service-http" for the service named "my-service". Note that target path in the rule is defined by the service annotation.

Moreover, the operator should always maintain a correct rule-set even if an annotation changes / disappears or a service is deleted, etc.

(We call this automation as an operator, but depending on the naming conventions sometimes the word "controller" is used instead for this simple task. See the references.)

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
      port: 80
      targetPort: 8080
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