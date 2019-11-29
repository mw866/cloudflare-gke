# Cloudflare Argo Tunnel in Kubernetes Sidecar Model

##  Commands
```
kubectl create -f sidecar.yaml
kubectl apply -f sidecar.yaml
kubectl get pods
kubectl describe pods
kubectl logs hello-78cd6696d-wd8sg tunnel
kubectl top node
```


## References
* [Argo Tunnel K8S Sidecar Guide](https://developers.cloudflare.com/argo-tunnel/reference/sidecar/)
* [My unofficial `cloudflared` build](https://hub.docker.com/repository/docker/mw866/cloudflared)
* [Merging an upstream repository into your fork](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/merging-an-upstream-repository-into-your-fork)
[My Container is terminated](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#my-container-is-terminated)

## Troubleshooting
### OOMKill Exit Code 137 
Solution: remove resource limit