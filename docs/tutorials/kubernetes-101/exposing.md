---
title: Exposing/routing traffic to pods
---

Let's explore different ways of exposing the running Pods to the outside world.

## Service

Kubernetes nodes all run a `kube-proxy` (or something similar) which allows the `Service` abstraction by proxying the traffic to the correct node where a `Pod` runs. Although there are actually endpoints between pods and services… it's complicated, but we don't need to care about `Endpoints` at all.

Remember those labels we set in the pod/deployment spec? They can be used to point a ``Service`` to your pod(s):

Services come in many flavors, here's a quick overview

- ClusterIP
    - For intra-cluster traffic, your pods are available behind a single IP and DNS name
- NodePort
    - For something like an ingress controller, this exposes your service on port X on all nodes
- LoadBalancer
    - This is typically spawns an external cloud resource (load balancer) pointing to your service, it uses the above two methods inside the cluster and does magic outside cluster to actually route the traffic. You can see the external IP in the cluster in the end, somehow. (well ok, there's a "Cloud Controller Manager" in the kube-system namespace, it's typically responsible for this magic show).

Let's create a `Service` of type `ClusterIP` pointing to our service for fun:

```yaml
#service.yaml
apiVersion: v1
kind: Service
metadata:
  name: veri-service
  labels:
    app: http-echo
spec:
  type: ClusterIP
  selector:
    app: http-echo
  ports:
  - port: 80
    protocol: TCP
    targetPort: 5678
```

Now let's try it out using a container that will be removed after we exit (`--rm`):

```bash
kubectl run -it --rm busybox --image=busybox -- /bin/sh
# wait for the prompt, try enter few times
wget -O- -q veri-service
```

You might not have noticed, but we actually set the service to expose the pod at port `80` instead of the port the container is configured with. Interesting... Or maybe not 🤷

## Port-forwarding

Exposing the service using ClusterIP didn't really help us to reach it outside the cluster. But we can also just hack the whole thing and use `kubectl` superpowers to route traffic to any pod:

```bash
kubectl port-forward deployment/veri-deployment 8080:5678
```

Try browsing to [http://localhost:8080](http://localhost:8080) and you should see your text there.

## Ingress

Ingress is for fancy L7 routing, similar to an API Gateway that some cloud providers offer. In fact; there's a new Kubernetes API called Gateway API which adds even more features on top of ingress features aiming to be able to be a cloud agnostic yet native API.

```yaml
#ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: veri-ingress
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /vericonf
        pathType: Prefix
        backend:
          service:
            name: veri-service
            port:
              number: 80
```

Navigate to [http://localhost:8081/](http://localhost:8081/) , what do you see?

Maybe it is the wrong path actually? Look at the manifest a bit. In addition to routing based on the URL/path, it's possible to configure multiple hosts and route traffic based on subdomains as an example.
