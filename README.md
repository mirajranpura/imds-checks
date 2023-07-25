# Description
This k8s daemon set provides quick insights on which worker node has ec2 instance meta-data(IMDSv1/v2) accessible from pods running in it. 


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


### Recommended references
* [EKS Best practices on restricting access to EC2 instance profile](https://aws.github.io/aws-eks-best-practices/security/docs/iam/#restrict-access-to-the-instance-profile-assigned-to-the-worker-node)<br>
* [IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
* [Configure instance metadata options for new instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-IMDS-new-instances.html)<br>
* [Modify instance metadata options for existing instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-IMDS-existing-instances.html)<br>

### How to use this repo with EKS / Self managed K8s cluster on AWS:

-----
> Usecase 1. Disabling both IMDS versions [ EKS Security best practice recommended]<br>

```aws ec2 modify-instance-metadata-options  --instance-id i-0628cxxxxxxxxx --http-endpoint enabled --http-put-response-hop-limit 1 --http-tokens required```

##### Pod logs output: 
```kubectl logs ds/imds -f  -n <NAMESPACE>```
```ruby
IMDS V1 for pods : Disabled
IMDS V2 for pods :  Disabled

Tue Jul 25 20:09:53 UTC 2023 ip-172-31-x-x.ec2.internal
```

-----
> Usecase 2. Enabling only IMDS V2 [**Against the Least privilege security piller**]<br>

```aws ec2 modify-instance-metadata-options  --instance-id i-0628cxxxxxxxxx --http-endpoint enabled --http-put-response-hop-limit 2 --http-tokens required```
##### Pod logs output: 
```kubectl logs ds/imds -f  -n <NAMESPACE>```
```ruby
IMDS V1 for pods : Disabled
IMDS V2 for pods : Enabled
 Found instance ID with IMDS v2:  i-0628cxxxxxxxxx
Tue Jul 25 20:20:00 UTC 2023 ip-172-31-x-x.ec2.internal
```

-----
> Usecase 3. Keeping both version enabled [**Never recommended**] <br>

```aws ec2 modify-instance-metadata-options  --instance-id i-0628cxxxxxxxxx --http-endpoint enabled --http-put-response-hop-limit 2 --http-tokens optional```
##### Pod logs output: 
```kubectl logs ds/imds -f  -n <NAMESPACE>```
```ruby
IMDS V1 for pods : Enabled
 Found instance ID with IMDS v1:  i-0628cxxxxxxxxx
IMDS V2 for pods : Enabled
 Found instance ID with IMDS v2:  i-0628cxxxxxxxxx
Tue Jul 25 20:20:00 UTC 2023 ip-172-31-x-x.ec2.internal
```


   

