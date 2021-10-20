#!/usr/bin/env bash

# Uses brew-install gnuutils prefixed with an extra "g". Fix if necessary.
PROJECT=$(ggrep project_id ../00-backend/terraform.tfvars | ggrep -Po '"\K[^"\047]+(?=["\047])')
STATE_BUCKET=$PROJECT-tfstate
export PROJECT
export STATE_BUCKET


envsubst < config.template > config.tf
terraform init
terraform plan
terraform apply -auto-approve

