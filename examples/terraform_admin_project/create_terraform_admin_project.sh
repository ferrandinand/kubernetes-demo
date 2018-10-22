 #!/bin/bash

#Terraform admin project
TERRAFORM_ADMIN="terraform-golondrina"
CREDENTIALS_FILE="${HOME}/.config/terraform-ernesto-admin.json"
ORG_ID="321376830469"
BILLING_ACCOUNT="01AA8B-6F0F9C-1F92B5"

terraform get
## Generamos el proyecto, lo linkamos a la billing account, creamos el IAM, activamos los servicios, generamos el fichero de backet, lo versionamos, y arrancamos el init con ese backend

#Deberia comprobar antes si existe el proyecto
gcloud projects create ${TERRAFORM_ADMIN} \
  --organization ${ORG_ID} \
  --set-as-default
#Por tanto si tiene linkada una cuenta
gcloud beta billing projects link ${TERRAFORM_ADMIN} \
  --billing-account ${BILLING_ACCOUNT}
#Tambien si existe esta cuenta IAM
gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"
#Y si es neceasrio crear las credenciales
gcloud iam service-accounts keys create ${CREDENTIALS_FILE} \
  --iam-account terraform@${TERRAFORM_ADMIN}.iam.gserviceaccount.com
#Y bindarlas
gcloud projects add-iam-policy-binding ${TERRAFORM_ADMIN} \
  --member serviceAccount:terraform@${TERRAFORM_ADMIN}.iam.gserviceaccount.com \
  --role roles/viewer

gcloud projects add-iam-policy-binding ${TERRAFORM_ADMIN} \
  --member serviceAccount:terraform@${TERRAFORM_ADMIN}.iam.gserviceaccount.com \
  --role roles/storage.admin

### añadp esta politica de IAM
  gcloud projects add-iam-policy-binding ${TERRAFORM_ADMIN} \
  --member serviceAccount:terraform@${TERRAFORM_ADMIN}.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser
#Es posible que esto ya este activo, pero no pasa nada.
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
## Esto tambien deberia comprobarse antes.
gcloud organizations add-iam-policy-binding ${ORG_ID} \
  --member serviceAccount:terraform@${TERRAFORM_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator
gcloud organizations add-iam-policy-binding ${ORG_ID} \
  --member serviceAccount:terraform@${TERRAFORM_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user
gsutil mb -p ${TERRAFORM_ADMIN} gs://${TERRAFORM_ADMIN}
#El backend se genera cada vez segun las variables
cat > backend.tf <<EOF
terraform {
 backend "gcs" {
   bucket  = "${TERRAFORM_ADMIN}"
   prefix  = "terraform/state"
   project = "${TERRAFORM_ADMIN}"
 }
}
EOF

gsutil versioning set on gs://${TERRAFORM_ADMIN}

export GOOGLE_APPLICATION_CREDENTIALS=${CREDENTIALS_FILE}
export GOOGLE_PROJECT=${TERRAFORM_ADMIN}
terraform plan