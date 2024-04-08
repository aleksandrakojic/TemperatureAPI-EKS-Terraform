# TemperatureAPI-EKS-Terraform
Deploying an EKS cluster using Terraform


1. Configuring the network (VPC, Subnets, NAT, etc)

2. Creating the EKS Cluster (Assuming roles, creating node groups, etc)

3. Configuring IAM OIDC with Kubernetes Service Accounts

4. Installing Application Load Balancer

5. Adding our Kubernetes resources to the cluster

6. Creating a Domain name & testing everything!

```shell
cd terraform/
terraform init
terraform apply --auto-approve
```

This usually takes 10 minutes or so to fully build.

`Moving on you'll need to have kubectl installed to be able to apply all the service`

Once finished, run the following to update your kube-config

```shell
aws eks --region eu-central-1 update-kubeconfig --name eks-cluster-production
```

Then set the default kubectl context to be your new EKS cluster

1. kubectl config view Then find the name of the new cluster

2. kubectl config set-context <name>

Create a separate namespace for the services below

```kubectl create namespace temp-calculator```


Now, Apply all the services & deployments below using ```kubectl apply -f <file-name>.yaml```

The Ingress uses the underlying ALB as the ingress controller, we annotate it with a couple of annotations as per AWS Documentation.

Finally if you have an existing domain, when you do ```kubectl get ingress -n temp-calculator``` you can see the Address for the ingress AWS provides us. All you need to do is add a CNAME record for your domain and point it to that value. If you have any questions feel free to reach me on Linkedin or Twitter! both linked in my profile

To Test the API just send a curl request as follows

```shell
curl -X GET "http://<domain>?from=Celsius&to=Kelvin&temperature=36"

# response
# {"value":309.15,"unit":"Kelvin"}
```

*Note: Make sure to do terraform destroy after you finish! as EKS costs 0.10$ per hour*