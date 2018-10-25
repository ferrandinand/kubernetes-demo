# POC Terraform, GKE, google build, stackdriver and traefik  
This is a PoC created in order to check how to create an infrastructure stack that would allow to deploy fast to production using kubernetes being able to do canary deployments or Blue/Green deployments.

For this demo we will use repo https://github.com/ferrandinand/whoami with deploy 2 branches, canary and master.
Once it is deployed to one of this two branches google build will trigger a build for this images and we can update the kubernetes deployment.

Tools used:
Terraform, GKE, Google build, stackdriver and Traefik

##Prerequisites
```Terraform v0.11.9
+ provider.google v1.19.1
+ provider.kubernetes v1.3.0
+ provider.null v1.0.0
+ provider.random v2.0.0
```

```Google Cloud SDK 222.0.0
+ alpha 2018.10.19
+ beta 2018.10.19
+ bq 2.0.36
+ core 2018.10.19
+ gsutil 4.34
+ kubectl 2018.10.19
```

##Setup google ENV vars
```GOOGLE_APPLICATION_CREDENTIALS=path/to/your/google_credentials.json
GOOGLE_PROJECT=google_project
```

Fill staging.tfvars with your parameters.

```billing_account = "google_billing_account"
project = "id_of_the_project"
repo_name = "ferrandinand-whoami"
client_email = "xxxxx@xxxx.com"
```

##Setup github
Create a repository mirror in google source repositories in order to setup github permissions.

##Run terraform
```terraform apply -var-file=staging.tfvars
```

Here we will have a kubernetes cluster running in gke, cloud build configured to trigger on repo deployment in branches master and canary and kubectl configured locally to run commands to our cluster.

##Deploy traefik
```kubectl apply -f traefik/
```

Get the external ip assigned for google to our load balancer and check traefik is working in http://x.x.x.x:8080 without backend configured.

##Deploy whoami app
deploy our whoami app in 50/50 with two backend(one for master, one for canary)
```kubectl apply -f services/whoami
```

Check how services are balanced in round robin.
```curl -H 'Host: whoami.traefikgke' 35.230.180.98
I'm not a star whoami-demo-7f646f8577-qvkzs
```

```
curl -H 'Host: whoami.traefikgke' 35.230.180.98
I'm a third version of a canary whoami-demo-canary-5447c9789d-qhdmj
```

At this moment if you commit something in the repo, a build will be triggered and a build will be need to make aware kubernetes that something change in the deploy.

```kubectl patch deployment deployments/whoami-demo-canary  -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
```

We can automate this in a pipeline but the best way to avoid this would be to deploy with helm and make a template with this.

##TODO
- Create an app pipeline develop locally, go to staging, canary and production (not updated image is required)
- Convert terraform module directories to repositories in order to version and pin them.
- Pin deployed versions to SHA to allow automatic updates.
- Insert a database instance which can interact with our pods.
- Remove hardcoded container image in services whoami.
- Convert kubernetes yaml manifests to Helm.
- Manage secrets in terraform and kubernetes for pods.
- Create a terraform pipeline.
