---
title: Scaling/rolling upgrades
---

For the adventurous you can edit deployments on the fly and modify the `replicas` field:

```bash
kubectl edit deployment veri-deployment
```

You can also edit the pod template and that will trigger the pods to be replaced, that might not happen in the nicest way though (unless you've defined a [PodDisruptionBudget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)).

Instead of editing the manifests, Kubernetes ships with some built-in ways to scale and upgrade a Deployment, including things like HorizontalPodAutoscaler. Instead of using automation, we can scale the thing ourselves or do a rolling upgrade:

```bash
kubectl scale deployment/veri-deployment --replicas=3
kubectl rollout status deployment/veri-deployment
kubectl get pods
```

It might/might not be interesting to you that it's also possible to scale to 0, you can try that as well.

We can also change some of the fields such as `env` or `image` imperatively:

```bash
kubectl set env deployment/veri-deployment -e ECHO_TEXT="Some other text"
kubectl get deployment/veri-deployment -o yaml | grep -i "env\:" -A2
```

I think this latest change is actually causing lots of bugs, I'm sure, let's just undo the whole thing and move on:

```bash
kubectl rollout undo deployment/veri-deployment
```

In production clusters you would rarely use the `kubectl set` or `kubectl rollout` commands, but occasionally you might use if upgrading a cluster and bumping some of the image versions of `kube-system`  DaemonSets for example. I'd recommend using GitOps controller such as [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) to manage your application deployments.
