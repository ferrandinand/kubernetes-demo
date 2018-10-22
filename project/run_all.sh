 #!/bin/bash
source scripts/setup_environment.sh

## Generamos el proyecto, lo linkamos a la billing account, creamos el IAM, activamos los servicios, generamos el fichero de backet, lo versionamos, y arrancamos el init con ese backend

#Deberia comprobar antes si existe el proyecto
gcloud projects create ${TF_ADMIN} \
  --organization ${TF_VAR_org_id} \
  --set-as-default
#Por tanto si tiene linkada una cuenta
gcloud beta billing projects link ${TF_ADMIN} \
  --billing-account ${TF_VAR_billing_account}
#Tambien si existe esta cuenta IAM
gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"
#Y si es neceasrio crear las credenciales
gcloud iam service-accounts keys create ${TF_CREDS} \
  --iam-account terraform@${TF_ADMIN}.iam.gserviceaccount.com
#Y bindarlas
gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/viewer

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/storage.admin

### añadp esta politica de IAM
  gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser
#Es posible que esto ya este activo, pero no pasa nada.
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
## Esto tambien deberia comprobarse antes.
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user
gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}
#El backend se genera cada vez segun las variables
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

#Aqui empieza
terraform get
terraform init

## Ejecutamos el plan con las variables del bucket

terraform plan
## Ejecutamos el apply con todo lo anterior
terraform apply


#output: 	verify-gcp-profile-set		## Vemos el output
#	terraform output -json	
#	
#verify-gcp-profile-set:
#ifndef GCP_PROFILE
#	$(error GCP_PROFILE is not defined. Make sure that you set your GCP profile and region.)
#endif
#ifndef GCP_DEFAULT_REGION
#	$(error GCP_DEFAULT_REGION is not defined. Make sure that you set your GCP region.)
#endif
#