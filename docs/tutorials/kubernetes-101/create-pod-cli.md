---
title: Create Pod (CLI)
---

Creating a pod can be done imperatively with a single command:

```bash
kubectl run --image=alpine alpine
```

Let's see what happened:

```bash
kubectl get pods
kubectl describe pod alpine
```

