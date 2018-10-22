.PHONY: all 

all: help
# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'


help:						## Show this help
							## CUIDADO! ESTE MAKEFILE NO FUNCIONA
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

setprofile: 					##Se cargan las variables de entorno
	source scripts/setup_environment.sh

get:		verify-gcp-profile-set 		## Get the terraform modules
	GCP_PROFILE=${GCP_PROFILE} terraform get

init: 		verify-gcp-profile-set 		## Generamos el proyecto, lo linkamos a la billing account, creamos el IAM, activamos los servicios, generamos el fichero de backet, lo versionamos, y arrancamos el init con ese backend
	gcloud projects create ${TF_ADMIN} \
	  --organization ${TF_VAR_org_id} \
	  --set-as-default
	
	gcloud beta billing projects link ${TF_ADMIN} \
	  --billing-account ${TF_VAR_billing_account}
	
	gcloud iam service-accounts create terraform \
	  --display-name "Terraform admin account"
	
	gcloud iam service-accounts keys create ${TF_CREDS} \
	  --iam-account terraform@${TF_ADMIN}.iam.gserviceaccount.com
	
	gcloud projects add-iam-policy-binding ${TF_ADMIN} \
	  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
	  --role roles/viewer
	
	gcloud projects add-iam-policy-binding ${TF_ADMIN} \
	  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
	  --role roles/storage.admin
	
	gcloud services enable cloudresourcemanager.googleapis.com
	gcloud services enable cloudbilling.googleapis.com
	gcloud services enable iam.googleapis.com
	gcloud services enable compute.googleapis.com
	
	gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
	  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
	  --role roles/resourcemanager.projectCreator
	  
	gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
	  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
	  --role roles/billing.user
	
	gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}
	
	cat > backend.tf <<EOF
	terraform {
	 backend "gcs" {
	   bucket  = "${TF_ADMIN}"
	   prefix  = "terraform/state"
	   project = "${TF_ADMIN}"
	 }
	}
	EOF
	
	gsutil versioning set on gs://${TF_ADMIN}
	
	export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
	export GOOGLE_PROJECT=${TF_ADMIN}
	
	terraform init

plan: 		verify-gcp-profile-set		## Ejecutamos el plan con las variables del proyecto
	
	source scripts/setup_project_vars.sh
	
	terraform plan
	
apply:		verify-gcp-profile-set		## Ejecutamos el apply con todo lo anterior
	terraform apply

ssh: 		verify-gcp-profile-set		## Inciamos sesion en la maquina instanciada
	scripts/ssh_instance.sh

output: 	verify-gcp-profile-set		## Vemos el output
	terraform output -json	
	
verify-gcp-profile-set:
ifndef GCP_PROFILE
	$(error GCP_PROFILE is not defined. Make sure that you set your GCP profile and region.)
endif
ifndef GCP_DEFAULT_REGION
	$(error GCP_DEFAULT_REGION is not defined. Make sure that you set your GCP region.)
endif
