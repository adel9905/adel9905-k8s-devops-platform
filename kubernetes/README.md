# Kubernetes Hands-on Guide

## Official Documentation

- **Kubernetes official documentation**: [https://kubernetes.io/docs/home/](https://kubernetes.io/docs/home/)
- **Minikube tutorial**: [https://kubernetes.io/docs/tutorials/hello-minikube/](https://kubernetes.io/docs/tutorials/hello-minikube/)

---

## Imperative Commands

### Create single container Pod
`kubectl run nginx --image=nginx --restart=Never`


### Create Pod with labels and annotations
kubectl run webserver-pod
--image=nginx:1.14.2
--restart=Never
--labels=app=webserver,environment=production
--annotations=description="This pod runs the nginx web server"


### Get Pod details
Complete details
`kubectl describe pod webserver-pod`

YAML format
`kubectl get pod webserver-pod -o yaml`


### Run temporary Pod (auto-delete)
kubectl run -i --tty testpod
--image=busybox
--rm --restart=Never -- sh


## Declarative Approach

### Generate YAML manifest
`kubectl run webserver-pod --image=nginx --dry-run=client -o yaml > pod.yaml`


## Multi-container Pod (Sidecar Pattern)

### Generate multi-container manifest
kubectl run multi-container-pod
--image=nginx
--dry-run=client -o yaml > multi-container-pod.yaml


### View container logs
`kubectl logs -f multi-container-pod -c webserver`
`kubectl logs -f multi-container-pod -c log-reader`



### Exec into containers
`kubectl exec -it multi-container-pod -c webserver -- sh`
`kubectl exec -it multi-container-pod -c log-reader -- sh`


### Port-forward to access
`kubectl port-forward pod/multi-container-pod 8080:80 &`


## Init Container Example

`kubectl apply -f init_container.yaml`
`kubectl port-forward pod/web-server-pod 8081:80 &`
`kubectl get pod web-server-pod -o jsonpath='{.status.podIP}'`

## ReplicaSets (A ReplicaSet is a Kubernetes object that ensures a specified number of identical pods are always running.)

**Reference**: [ReplicaSet Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)

### Apply ReplicaSet
`kubectl apply -f replicaset.yaml`
`kubectl get replicasets` or `kubectl get rs`
`kubectl get pods`

### Filter Pods by labels
`kubectl get pods -l tier=frontend,app=guestbook`
`kubectl get pods -l tier=frontend,app=guestbook -L tier,app`


### Test ReplicaSet behavior
Delete a pod - ReplicaSet will recreate it automatically to keep desired state
`kubectl delete pod <pod-name>`

Apply pod with same labels - ReplicaSet manages it (no new pod created) with desired no of replicas.
`kubectl apply -f pod_with_same_labels_rs.yaml`

Scale Replicasets using kubectl
`kubectl scale rs frontend --replicas=5`

Deleting a Replicaset
`kubectl delete rs frontend`


## Deployments (A Deployment in Kubernetes is used to manage and run your application pods through ReplicaSets.)

**Reference**: [Deployments Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

Apply Deployment
`kubectl apply -f deployment.yaml`

Perform a rolling update, replace image nginx from nginx:1.25.4 to nginx:1.14.2
`k edit deploy nginx-deployment` or modify the deployment.yaml file to update in a declarative way

To verify the status of rollout
`kubectl rollout status deploy nginx-deployment`

To verify the history of rollout
`kubectl rollout history deploy nginx-deployment`

To annotate the change of the deployment
`kubectl annotate deploy nginx-deployment kubernetes.io/change-cause="Updated the deployment with latest Nginx Image"`

To rollback or undo the deployment
`kubectl rollout undo deploy nginx-deployment`

To pause or freeze deployment - Mainly during incidents you may have to do multiple changes taking all at once.
`kubectl rollout pause deploy nginx-deployment`

To resume back deployment
`kubectl rollout resume deploy nginx-deployment`

To check the metrics of pods (cpu/memory)

## HPA (Horizontal Pod Autoscaler)

**Reference**: [HPA Documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

To use HPA, metrics addon is to be enabled in minikube. By defauly in EKS its enabled for cluster. 

`minikube addons enable metrics-server`

HPA works for Deployment, Replicaset and Statefulsets.
`kubectl apply -f hpa.yaml`

Expose the Service 
`kubectl expose deployment nginx-deployment --type=ClusterIP --port=80`

Test HPA by generating load
`kubectl run loadgen --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- nginx-deployment:80; done"`

`kubectl get hpa nginx-hpa -w`


## Labels and Selectors

**Reference**: [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)

`kubectl apply -f deployment_equality_based_selector.yaml`

`kubectl get pods -l app=payment,tier=backend,environment=prod`

`kubectl apply -f deployment_set_based_selector.yaml`


## Requests and Limits

**Pod Quality of Service (QoS)**:

**Reference:** [Pod Quality of Service](https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/)

**Scenarios 1:** Without Specifying Resources
When you deploy a pod without specifying any resource requests or limits, Kubernetes will not reserve any specific amount of CPU or memory for the pod. This can lead to overcommitment on the node.

**Scenario 2:** Specifying Requests and Limits
When you specify resource requests and limits in the pod configuration, Kubernetes uses the request value to ensure the node has sufficient resources to run the pod. However, if multiple pods try to utilize all their limit ranges, the node can become overcommitted (Resource Pressure)

To manage resource overcommitment and prioritize 
- Best Effort (pod with no reqests and limits set)   **Lowest priority**
- Guaranteed (pod with same requests and limits set)  **High Priority**
- Burstable (pod with low requests and high limits set) **Low priority**

**Resource Quota** 

**Reference**: [Resource Quota](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
A kubernetes cluster can be used by 
- single
- multiple teams(Such as shared cluster) Teams get access to specific namespace using RBAC.
   - It helps to track how much each team is exactly using cluster resources, helpful for cost allocation and ensuring no single team using all cluster resources
   - Important for compliance, isolating teams to specific namespaces easy to enforce security and operational policies more effectively

So, to ensure that the end users do not use all the resources in the cluster, Kubernetes offers a namespace-scoped object called **ResourceQuota**

To address challenges of shared cluster resources, especially in multi-tenant/team scenarios, its advisable touse Kubernetes Resource Quota object.

It sets hard limits on the resources a namespace can use like CPU, Memory. Each team ensures a fair amount of cpu/memory to keep cluster healthy and stable.

Primary purpose of using:
 - Resource Limitation: Ensures no single team can make use all cluster resources
 - Fair Distribution: Helps to distribute resources based on their needs
 - Cluster Stability: It keeps cluster stable by preventing resource exhaustion
 - Cost Management: Helps to control costs and predict by setting resource limits
 - Isolation: Isolating workloads and organizing each team uses and provides security and complicance

With Resource Quota, we can limit the following per namespace
1. CPU and Memory Requests and Limits
2. Pod and Container limits
3. Persistent volume claims and amout of storage requested by PVC
4. Max no of services, configmaps, secrets, replicationcontrollers, resourcequota etc

Lets try to explore by testing:
1. Create namespace trainxops
`kubectl create ns trainxops`

2. Define resourcequota.yaml with all limits
`kubectl apply -f resourcequota.yaml`

3. Verify the quota set to namespace
`kubectl get quota -n trainxops`

also you can use describe command for better readability
`kubectl describe quota trainxops-quota -n trainxops`


Try to create a pod by not specifying requests and limits

`kubectl apply -f pod.yaml -n trainxops`

It fails with error because it falls under Best effort class and might consume all resurces in namespace

Lets set some limits to a pod to assign some default values if nothing set

### Create limitrange.yaml file
`kubectl apply -f limitrange.yaml`

`kubectl get limitrange -n trainxops`

`kubectl describe limitrange pod-limits -n trainxops`

### Try to create a pod in trainxops namespace

`kubectl apply -f pod.yaml -n trainxops`