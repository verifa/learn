---
title:  Creating Pod (Declarative)
---

You never should run just `Pod` in production, when a pod is deleted it's gone forever. Instead of `Pod` you use a higher level controller such as a `Deployment`.

You can refer to official docs for more examples: [https://kubernetes.io/docs/concepts/workloads/pods/](https://kubernetes.io/docs/concepts/workloads/pods/)

Modify the manifest below to use the `verifa/http-echo:latest` image:

```yaml
#pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: http-echo
spec:
  containers:
  - name: http-echo
    image: <HERE>
    ports:
    - containerPort: 5678
```

Note that the `containers` field is a list, you can specify multiple containers here that share the same IP/network and filesystem. That's why it's a `Pod` not a container.

Apply the manifest using `kubectl` and use the `get` and `describe` verbs to view it:

```bash
kubectl apply -f pod.yaml
kubectl get pods
kubectl describe pod http-echo
```

Observe the pod with the commands and see if it starts up, you probably need to spam the commands a few times since it might take a while to pull the image.


??? info "Expand this after checking the pod status few times"

    ![crashloop-meme](../../assets/images/crashloop-meme.png)

    Sorry, we set you up for failure. Use a command to check the logs to see what happened:
   
    ```bash
    kubectl logs http-echo
    ```
    
    Hmm, maybe something missing?
    
    Add the necessary environment variable to the manifest to get it running:
    
    ```bash
    #pod.yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: http-echo
    spec:
      containers:
      - name: http-echo
        image: <HERE>
        **env:
        - name: ECHO_TEXT
          value: <WRITE_SOMETHING_FUNNY_HERE>**
        ports:
        - containerPort: 5678
    ```
    

If you need to you can delete the pod in 2 ways:

```bash
kubectl delete pod <pod-name>
kubectl delete -f pod.yaml
```

    
!!! tip "For help with manifests"
    
    You can use the `kubectl explain` command to help you while writing manifests, try it with:
    ```bash
    kubectl explain pod.spec.containers
    kubectl explain pod --recursive
    ```
    
    Another tool some find helpful is: [https://k8syaml.com/](https://k8syaml.com/) But it does not directly support Pods, since nobody writes pod manifests directly, next we look at what you would write instead.
    

