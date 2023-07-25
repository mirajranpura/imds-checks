# Description
This k8s daemon set provides insight over which worker node has ec2 instance meta-data accessible for pods  (Both IMDSv1 and IMDSv2).


## Deployment steps

1. Clone this repo and switch to root directory<br>
   
2. Create k8s configMap called 'imds-finder' that holds a shell script<br>
   ```kubectl create configmap imds-finder --from-file=imds.sh=imds.sh -n <NAMESPACE>```
3. Create K8s DaemonSet called 'imds' that runs the script in the pod and verify if the IMDSv1/v2 are accessible<br>
   ```kubectl apply -f ds.yaml -n <NAMESPACE>```
4. Check the logs of the DaemonSet 'imds'. <br>
   ```kubectl logs ds/imds -f  -n <NAMESPACE>```

### To block both IMDSv1 and IMDSv2 for the pods running on AWS EC2 instances (EKS Worker nodes)

| WARNING: Blocking access to instance metadata will prevent pods that do not use IRSA from inheriting the role assigned to the worker node! |
| --- |

```aws ec2 modify-instance-metadata-options  --instance-id i-0628cxxxxxxxxx --http-endpoint enabled --http-put-response-hop-limit 1 --http-tokens required```


### EKS Best Practices on blocking IMDS and using IRSA feature for the pods
https://aws.github.io/aws-eks-best-practices/security/docs/iam/#restrict-access-to-the-instance-profile-assigned-to-the-worker-node 

