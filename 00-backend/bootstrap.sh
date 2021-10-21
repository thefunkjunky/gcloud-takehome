#!/usr/bin/env bash

# Uses brew-install gnuutils prefixed with an extra "g". Fix if necessary.
PROJECT=$(ggrep project_id terraform.tfvars | ggrep -Po '"\K[^"\047]+(?=["\047])')
BUCKET=$PROJECT-tfstate
export BUCKET

if gsutil ls gs://$BUCKET; then
  echo "GCS backend bucket gs://$BUCKET already exists"
  terraform init
  terraform apply -auto-approve
else
  rm -f config.tf
  rm -f config-local.tf
  # Remove backend code block for temp config
  sed '/^  backend "gcs" {$/,/^  }/d' config.template > config-local.tf
  terraform init -migrate-state -force-copy
  terraform apply -target=google_project.helloworld -lock=false -auto-approve
  gcloud config set project $PROJECT
  gcloud auth application-default login
  terraform apply -target=google_storage_bucket.tfstate -lock=false -auto-approve
  rm -f config-local.tf
  envsubst < config.template > config.tf
  terraform init -migrate-state -force-copy
  terraform plan
  terraform apply -auto-approve
fi
