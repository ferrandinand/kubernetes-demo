# Terraform-admin
Antes de empezar coger las credenciales de la service account

``
export GOOGLE_APPLICATION_CREDENTIALS=/Users/ernesto/.config/gcloud/terraform-ernesto.json
``
Se crea un proyecto con una cuenta de servicio terraform que 
permite generar proyectos y cuentas de facturacion y con el state en un bucket

Se crea un cluster de kubernetes bla bla...

...

Podemos encontrarnos este error
 google_container_cluster.new_container_cluster: googleapi: Error 400: The user does not have access to service account "terraform@terraform-ernesto.iam.gserviceaccount.com". Ask a project owner to grant you the iam.serviceAccountUser role on the service account., badRequest


Aqui se explica el motivo:
https://medium.com/@josephbleroy/using-terraform-with-google-cloud-platform-part-1-n-6b5e4074c059


