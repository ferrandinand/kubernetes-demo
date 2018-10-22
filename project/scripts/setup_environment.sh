#!/bin/bash
export TF_VAR_org_id=321376830469
export TF_VAR_billing_account=01AA8B-6F0F9C-1F92B5
export TF_ADMIN=terraform-wedoops
export TF_CREDS=~/.config/gcloud/terraform-wedoops.json
echo $TF_VAR_org_id
echo $TF_VAR_billing_account
echo $TF_ADMIN
echo $TF_CREDS