# Configuracion de Terraform para GCP

Se tienen que cargar las variables de organizacion, billing account etc.. con

``
source scripts/setup_environment.sh
``

Una vez cargadas, creamos un proyecto y lo enlazamos a la billing account. Ojo, este va a ser el *projecto de administracion de terraform*

``
gcloud projects create ${TF_ADMIN} \
  --organization ${TF_VAR_org_id} \
  --set-as-default
``

``
gcloud beta billing projects link ${TF_ADMIN} \
  --billing-account ${TF_VAR_billing_account}
``


Una vez creado el proyecto, vamos a crear una service account para el

``
gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"
``

``
gcloud iam service-accounts keys create ${TF_CREDS} \
  --iam-account terraform@${TF_ADMIN}.iam.gserviceaccount.com
``

Le damos persmisos a la service account como Admin project viewer y Storage Admin
``
gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/viewer
``
``
gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/storage.admin
``

Activaamos los siguientes servicios
``
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
``

## Organization/folder-level permissions

TEnemos que añadir a la service account permisos para crear proyectos y asignar billing accounts
``
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator
``

``
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user
``

## Configuramos el bucket remoto
Create the remote backend bucket in Cloud Storage and the backend.tf file for storage of the terraform.tfstate file:

``
gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}
``

``
cat > backend.tf <<EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_ADMIN}"
   prefix  = "terraform/state"
   project = "${TF_ADMIN}"
 }
}
EOF
``

Activamos el versionado para este bucket

``
gsutil versioning set on gs://${TF_ADMIN}
``

Configuramos el enviroment

``
export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_ADMIN}
``

Una vez seguidos estos pasos inicializamos el backend

``
terraform init
``


## Ejemplo para crear un projecto y su instancia de Compute Engine

** Se crea el archivo project.tf **
Este archivo necesita los siguientes recursos
Terraform resources used:

> provider "google": The Google cloud provider config. The credentials will be pulled from the > GOOGLE_CREDENTIALS environment variable (set later in tutorial).
> resource "random_id": Project IDs must be unique. Generate a random one prefixed by the > desired project ID.
> resource "google_project": The new project to create, bound to the desired organization ID > and billing account.
> resource "google_project_services": Services and APIs enabled within the new project. Note > that if you visit the web console after running Terraform, additional APIs may be implicitly > enabled and Terraform would become out of sync. Re-running terraform plan will show you > these changes before Terraform attempts to disable the APIs that were implicitly enabled. > You can also set the full set of expected APIs beforehand to avoid the synchronization issue.
> output "project_id": The project ID is randomly generated for uniqueness. Use an output > variable to display it after Terraform runs for later reference. The length of the project > ID should not exceed 30 characters.
> 

** Se crea el aarchivo compute.tf **
Este archivo necesita los siguientes recursos:

> data "google_compute_zones": Data resource used to lookup available Compute Engine zones, > bound to the desired region. Avoids hard-coding of zone names.
> resource "google_compute_instance": The Compute Engine instance bound to the newly created > project. Note that the project is referenced from the google_project_services.project > resource. This is to tell Terraform to create it after the Compute Engine API has been > enabled. Otherwise, Terraform would try to enable the Compute Engine API and create the > instance at the same time, leading to an attempt to create the instance before the Compute > Engine API is fully enabled.
> output "instance_id": The self_link is output to make it easier to ssh into the instance > after Terraform completes.
> 

podemos setear las variables de entorno que necesitamos con 

``
source scripts/setup_project_vars.sh
``

Ahora ya estamos preparados para lanzar el plan

``
terraform plan
``

y aplicar

``
terraform_apply
``

una vez hecho esto podemos usar el script ssh_instance para iniciar sesion en la maquina que hemos creado

``
scripts/ssh_instance.sh
``


---

## Cleaning up

Para volver a dejar todo como estaba es neceasrio realizars las siguientes acciones

- Eliminamos la infra que hemos creado:

``
terraform destroy
``

- Borramos el proyecto:

``
gcloud projects delete ${TF_ADMIN}
``

- Por ultimo nos cargamos a nivel de organizacion los permisos de esta service acccount:

``
gcloud organizations remove-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator
``

``
gcloud organizations remove-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user
``



