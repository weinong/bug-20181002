# bug-20181002

## setup

k8s 1.11.2

## How to repro

Download the kubeconfig and run

```sh
./loop.sh my-kube-config
```

This script will keep creating load balancer typed service and delete them.

At the same time, restarting kube-controller-manager every 5 minutes.

At some point (for one of my repro, it took 15 minutes), the controller manager will be stuck in deleting IP:

```
I1002 22:08:02.700358       1 event.go:221] Event(v1.ObjectReference{Kind:"Service", Namespace:"default", Name:"svc2-svc", UID:"05709b57-c68c-11e8-9483-92fafe142ac2", APIVersion:"v1", ResourceVersion:"9739", FieldPath:""}): type: 'Normal' reason: 'EnsuringLoadBalancer' Ensuring load balancer
E1002 22:08:02.971844       1 azure_backoff.go:364] processHTTPRetryResponse: backoff failure, will retry, HTTP response=400, err=network.PublicIPAddressesClient#Delete: Failure sending request: StatusCode=400 -- Original Error: Code="PublicIPAddressCannotBeDeleted" Message="Public IP address /subscriptions/8ecadfc9-d1a3-4ea4-b844-0d9f87e4d7c8/resourceGroups/MC_ww-wcus_ww-new-3_westcentralus/providers/Microsoft.Network/publicIPAddresses/kubernetes-a6d151c41c68a11e8948392fafe142ac can not be deleted since it is still allocated to resource /subscriptions/8ecadfc9-d1a3-4ea4-b844-0d9f87e4d7c8/resourceGroups/MC_ww-wcus_ww-new-3_westcentralus/providers/Microsoft.Network/loadBalancers/kubernetes/frontendIPConfigurations/a6d151c41c68a11e8948392fafe142ac." Details=[]
E1002 22:08:02.971927       1 service_controller.go:219] error processing service default/svc2-svc (will retry): failed to ensure load balancer for service default/svc2-svc: timed out waiting for the condition
I1002 22:08:02.972130       1 event.go:221] Event(v1.ObjectReference{Kind:"Service", Namespace:"default", Name:"svc2-svc", UID:"05709b57-c68c-11e8-9483-92fafe142ac2", APIVersion:"v1", ResourceVersion:"9739", FieldPath:""}): type: 'Warning' reason: 'CreatingLoadBalancerFailed' Error creating load balancer (will retry): failed to ensure load balancer for service default/svc2-svc: timed out waiting for the condition
```
