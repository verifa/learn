---
title: Creating Deployment
---

Deployment is a controller for pods, you create a template for a pod and run X replicas of the pod. In a deployment all the replicas of the pods are stateless, meaning the names of the pod are  dynamic.

Modify the below manifest to include the pod spec from the `pod.yaml`:

```yaml
#deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: veri-deployment
  labels:
    app: http-echo
spec:
  replicas: <?>
  selector:
    matchLabels:
      app: http-echo
  template:
    metadata:
      labels:
        app: http-echo #needs to match with selector for Deployment to find pod!
    spec:
      <your-code-comes-here>
```

Again deploy the manifest and use `get`/`describe` to view the status of the deployment:

```bash
kubectl get deployments
kubectl get deployment veri-deployment
kubectl describe deployment veri-deployment
```

You can refer to official docs for more examples: [https://kubernetes.io/docs/concepts/workloads/deployments/](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

??? tip "If you're struggling with yaml or short on time, you can get the completed manifest under here"
    
    ```yaml
    #deployment.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: veri-deployment
      labels:
        app: http-echo
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: http-echo
      template:
        metadata:
          labels:
            app: http-echo #needs to match with selector for Deployment to find pod!
        spec:
          containers:
          - name: http-echo
            env:
            - name: ECHO_TEXT
              value: "Wohoo"
            image: verifa/http-echo:latest
            ports:
            - containerPort: 5678
    ```

