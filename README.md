# Cloudflare x GKE - Proof of Concepts

Some proof-of-concepts that demonstrate how Cloudflare can work with GKE.

## Getting started

### Step 0: Prerequisites: 
* `gcloud` and GCP account
* `terraform` 
* Cloudflare account with Argo enabled. 

### Step 1: Bootstrap the GKE environment with Terraform
1.1: Set the input variables by updating `gke.tf` with  or `export TF_VAR_resource_prefix=PREFIX` & `export TF_VAR_gcp_project_id=GCP_PROJECT_ID`

1.2: Check the output of `terraform plan`

1.3: Run `terraform run` and wait

### Step 2: Deploy your workloads to to the GKE environement with `kubectl`

2.1 Connect to the cluster
`gcloud container clusters get-credentials CLUSTER_NAME ` or follow the instructions in GCP Console -> Kubernetes Engine ->  Clusters

2.2 Run some kubectl to make sure it's configured correctly.
`kubectl config get-contex`


2.3 The foundation has been laid. The fun starts from here...



## `cloudflared-sidecar.yaml`:  Cloudflare Argo Tunnel in Sidecar Model with Cloudflare Load Balancer
### Architecture
![cloudflared-sidecar](./images/cloudflared-sidecar.jpg)



### Integration with Cloudflare

1. `kubectl create secret generic cloudflared-cert --from-file="$HOME/.cloudflared/cert.pem"`
2. `k apply  -f cloudflared-sidecar.yaml`
3. Check Cloudflare dashboard > Traffic > Argo Tunnel

### References
* [Argo Tunnel K8S Sidecar Guide](https://developers.cloudflare.com/argo-tunnel/reference/sidecar/)


#### OOMKill Exit Code 137 
Solution: remove resource limit
[My Container is terminated](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#my-container-is-terminated)



## `gke-ingress.yaml `: Cloudflare with GKE Ingress with GKE External Load Balancer

### Architecture: 
![gke-ingress](./images/gke-ingress.jpg)


### Integration with Cloudflare

1. Run `k apply -f gke-ingress.yaml`
2. Get the external IP address with `kubectl get ingress`  
3. Add it to Cloudflare DNS as an origin 

### References
* [Using Kubernetes on GKE and AWS with Cloudflare Load Balancer](https://support.cloudflare.com/hc/en-us/articles/115003384591-Using-Kubernetes-on-GKE-and-AWS-with-Cloudflare-Load-Balancer)
* [Setting up HTTP Load Balancing with Ingress](https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer)
* [HTTP(S) load balancing with Ingress](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress)
* [Configuring load balancing through Ingress](https://cloud.google.com/kubernetes-engine/docs/how-to/load-balance-ingress)
* [GKE Exposing applications using services - ClusterIP vs NodePOrt vs LoadBalancer etc](https://cloud.google.com/kubernetes-engine/docs/how-to/exposing-apps)
* [ClusterIP vs NodePOrt vs LoadBalancer etc](https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0)
* [Making Load Balancer IP Static](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#static_ip_addresses_for_https_load_balancers)


### Error 400 when creating ingress
`Error during sync: error running load balancer syncing routine: loadbalancer default-cwang-httpbin-ingress--6029373544ea4799 does not exist: googleapi: Error 400: STANDARD network tier (the project's default network tier) is not supported: STANDARD network tier is not supported for global forwarding rule., badRequest`

Just set the Network Service Tier to Premium. 
[Using Network Service Tiers](https://cloud.google.com/network-tiers/docs/using-network-service-tiers)


## `cloudflared-trailer.yaml`: Cloudflare Argo Tunnel in "Trailer" mode without Cloudflare Load Balancer or GCP Forwarding Rule

### Architecture: 
![cloudflared-trailer](./images/cloudflared-trailer.jpg)

### Integration with Cloudflare

1. `kubectl create secret generic cloudflared-cert --from-file="$HOME/.cloudflared/cert.pem"`
1. Run `k apply  -f cloudflared-trailer.yaml`
3. Check Cloudflare dashboard > Traffic > Argo Tunnel

### Error - cloudflared listening to service

 time="2019-12-05T06:18:49Z" level=error msg="unable to connect to the origin" error="Get http://10.112.9.183:80: dial tcp 10.112.9.183:80: connect: connection refused"


The service is not working. 
```
kubectl run -it --rm --restart=Never alpine --image=alpine sh

If you don't see a command prompt, try pressing enter.
/ # wget -O- cwang-gke-int-lb-service
Connecting to cwang-gke-int-lb-service (10.112.9.183:80)
wget: can't connect to remote host (10.112.9.183): Connection refused
```

Service is not associated with the correct deployment?
```
kubectl describe  endpoints cwang-gke-int-lb-service
Name:         cwang-gke-int-lb-service
Namespace:    default
Labels:       app=cwang-gke-int-lb-app
Annotations:  <none>
Subsets:
Events:  <none>
```

## References

### Misc
* [My unofficial `cloudflared` build](https://hub.docker.com/repository/docker/mw866/cloudflared)
* [Merging an upstream repository into your fork](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/merging-an-upstream-repository-into-your-fork)

### GKE and Kubernetes

* [Labels & Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
* [GKE Network Overview](https://cloud.google.com/kubernetes-engine/docs/concepts/network-overview)
* [Using environment variables inside of your config](https://kubernetes.io/docs/tasks/inject-data-application/efine-environment-variable-container/#using-environment-variables-inside-of-your-config)
* [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
* [Labels, Selectors, and MatchingLabels](https://medium.com/@zwhitchcox/matchlabels-labels-and-selectors-explained-in-detail-for-beginners-d421bdd05362)


### Terraform with GKE

* [Official Terraform docs on `google_container_cluster`](https://www.terraform.io/docs/providers/google/r/container_cluster.html)
* [Learn Terraform (with GCP)](https://learn.hashicorp.com/terraform/gcp/intro)

### `kubectl` Cheatsheet 
```
kubectl config current-context 
kubectl create -f FILE.yaml
kubectl apply -f FILE.yaml
kubectl delete -f FILE.yaml
kubectl get namespace
kubectl config get-contexts  
kubectl get po --output wide
kubectl describe pods
kubectl logs POD_NAME CONTAINER_NAME
kubectl top node
kubectl get ingress INGRESS_NAME --output yaml
kubectl exec POD_NAME   -- printenv | grep SERVICE   
kubectl exec -it POD_NAME -- /bin/bash
kubectl run -it --rm --restart=Never alpine --image=alpine sh
kubectl get endpoints
kubectl scale deploy tunnel --replicas=2

```

### `terraform` Cheatsheet
```
terraform show gke.tf
```
