#!/bin/bash
export TF_VAR_org_id=169823225828
export TF_VAR_billing_account=01630F-C94C29-E9D845
export TF_ADMIN=terraform-${USER}
export TF_CREDS=~/.config/gcloud/terraform-${USER}.json

echo $TF_VAR_org_id
echo $TF_VAR_billing_account
echo $TF_ADMIN
echo $TF_CREDS
