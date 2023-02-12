# tf-eks-fluxcd-quickstart

tf-eks-fluxcd-quickstart is a set of Terraform-based automation to create a demonstration [AWS EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
wired up for [FluxCD GitOps](https://fluxcd.io/flux/). It can be used on a bare AWS account and creates all
the EKS clusters AWS dependencies (VPC, roles...) as well as a dedicated GitHub repository for FluxCD.

This project is intended to be primarily a learning tool and lacks the observability, hardening, autoscaling, and
configuration flexibility required for production use. It has been optimized for simplicity, ease of use, and 
comprehensibility.

Following the quickstart guide below, Terraform will create a new GitHub repository that will contain the Kubernetes manifests that
FluxCD will sync with your EKS cluster. Once complete, committing changes to this repo will cause FluxCD to attempt to
reconcile those changes with your EKS cluster.

## fluxcd-manifests

In addition to Terraform automation, this repo contains a [fluxcd-manifests](./fluxcd-manifests) directory. Any yaml
file you place in this directory before running the quickstart steps below will be automatically committed to your new
FluxCD repo and synced to your new EKS cluster. 

## Continuous Deployment and tcphello

Already present in the `fluxcd-manifests` directory are manifests describing a demonstration service - [tcphello](https://github.com/eyablonowitz/tcphello).
tcphello is a simple service that listens on port 12345/tcp and responds with a friendly hello when it receives a TCP
connection.

The tcphello [kustomize](https://kustomize.io) [FluxCD resource](./fluxcd-manifests/tcphello.yaml) is explicitly linked to the
[kustomization in the tcphello repo](https://github.com/eyablonowitz/tcphello/tree/main/kustomize). This lets FluxCD
continuously deploy changes to tcphello when they are committed to its repo. Adding more services to the cluster is as
simple as adding their Kustomization or HelmRelease resources to your new FluxCD repo. For example, you can add the
podinfo service by following this [Deploy podinfo application](https://fluxcd.io/flux/get-started/#deploy-podinfo-application)
guide.

## ingress-nginx and the AWS Load Balancer Controller

On your cluster, tcphello will be deployed in a resilient manner with two replicas proxied by the [ingress-nginx controller](https://github.com/kubernetes/ingress-nginx).
Ingress-nginx is load balanced by an [AWS Network Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html)
managed by the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/).

By utilizing ingress-nginx, many HTTP, raw TCP, and UDP services can share the same load balancer, minimizing costs
and resource sprawl. Have a look at the [tcp section of the ingress-nginx.yaml manifest](./fluxcd-manifests/ingress-nginx.yaml#L41-L42)
to see how additional TCP services can be easily wired up to ingress-nginx. As with the tcphello manifest, this manifest
will automatically be committed to your new FluxCD repo, and you can modify it in-place in the new repo as required.

## Quickstart

### Prerequisites

These are the bare requirements to run the automation:
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) >=v1.3
- An AWS [access key](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) 
  corresponding to an account admin user (or alternative CLI admin access - e.g. SSO)
- A GitHub [access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
  with the rights to create a repository

In addition, you will need these tools to explore what has been created:
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [flux CLI](https://fluxcd.io/flux/cmd/)
- nc/netcat

### Bootstrap

We will start by running the bootstrap module which will:
- Create the new GitHub repo that FluxCD will sync with our cluster
- Commit FluxCD manifests from the `fluxcd-manifests` directory to the new repo
- Create a GitHub repo [deploy key](https://docs.github.com/en/developers/overview/managing-deploy-keys#deploy-keys) in
  the repo that FluxCD will use for auth

To start the bootstrap, clone this repo. And from the repo root run:

```shell
terraform -chdir=modules/bootstrap init &&  \
terraform -chdir=modules/bootstrap apply \
-var="github_owner=<the github-owner/org for your new repo>" \
-var="github_token=<your github access token>" \
-var="github_repo_name=<new fluxcd repo name>" \
-var="aws_resource_name=<name of EKS cluster, VPC... to be created in AWS>"
```

> *Note: this process should not write your GitHub token to local state. But it may save it in your shell history.
> You may prefer to omit your token from the command-line in which case Terraform will prompt you for it. Once
> the bootstrap is complete, Terraform and FluxCD will only use the newly created deploy key going forward, not your
> access token.*

Once the bootstrap completes you can verify the existence of your new GitHub repository in the UI. It should
contain any yaml files from `fluxcd-manifests` already populated into the `clusters/<cluster-name/` directory.

### EKS/FluxCD

Now we are ready to create the EKS cluster and wire it up to the FluxCD repo created in the bootstrap. This step will
consume [remote state](https://developer.hashicorp.com/terraform/language/state/remote-state-data) from the bootstrap
freeing us from the need to supply the same information again. It will create:
- A basic VPC complete with private/public/infra subnets, routes, and an Internet Gateway
- A basic EKS cluster with 2 t3-small nodes

> *AWS resources will be created in us-west-2 by default. You can override this using the `region` input variable*

This next step will make changes to your AWS account. It is advisable to ensure that Terraform will use the account and
user/role that you expect. To verify this, you can inspect the output of:
```shell
aws sts get-caller-identity
```

Once verified, from the repo root run:
```shell
terraform init && \
terraform apply
```

This should generate a plan that will create many new resources. No resources should be changed or destroyed at this 
point. If your plan *does* include change/destroy actions, it is advised that you answer "no" when prompted to apply.
Otherwise, answer yes.

### Have a look

Upon successful completion, FluxCD should immediately begin syncing your new EKS cluster to the GitHub repo created in
the bootstrap stage. You can verify this locally with the `kubectl` and `flux` cli tools. To point these tools to your
cluster, run:

```shell
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw eks_cluster_name)
```

#### Check the status of pods
ingress-nginx:
```shell
kubectl -n ingress-nginx get pod
```

Expect output like:
```shell
NAME                                                     READY   STATUS    RESTARTS   AGE
ingress-nginx-ingress-nginx-controller-9df4dd565-9pc56   1/1     Running   0          102m
ingress-nginx-ingress-nginx-controller-9df4dd565-cvqlq   1/1     Running   0          102m
```

tcphello:
```shell
kubectl -n tcphello get pod
```

Expect output like:
```shell
NAME                      READY   STATUS    RESTARTS   AGE
tcphello-cb448d6c-h7rlq   1/1     Running   0          104m
tcphello-cb448d6c-z99wj   1/1     Running   0          103m
```

#### Get the DNS name of the ingress-nginx load balancer
```shell
kubectl -n ingress-nginx \
get service ingress-nginx-ingress-nginx-controller \
-o=jsonpath="{.status.loadBalancer.ingress[0].hostname}"
```

Expect output like:
```shell
k8s-ingressn-ingressn-0bc9c82a42-76b366f6920d47fa.elb.us-west-2.amazonaws.com
```

#### Connect to the tcphello service
```shell
nc -v $(kubectl -n ingress-nginx \
get service ingress-nginx-ingress-nginx-controller \
-o=jsonpath="{.status.loadBalancer.ingress[0].hostname}") \
12345
```
Expect output like:
```shell
Connection to k8s-ingressn-ingressn-0bc9c82a42-76b366f6920d47fa.elb.us-west-2.amazonaws.com port 12345 [tcp/italk] succeeded!
Hello, ::ffff:10.0.10.143!
```
