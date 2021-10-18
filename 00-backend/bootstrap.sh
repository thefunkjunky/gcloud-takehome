#!/usr/bin/env bash

PROJECT=$(gcloud config get-value project)
BUCKET=$PROJECT-tfstate

if gsutil ls gs://$BUCKET; then
  echo "GCS backend bucket gs://$BUCKET already exists"
  terraform init
  terraform apply -auto-approve
else
  cp config.tf.old config.tf
  terraform init -force-copy
  terraform apply -target=google_storage_bucket.tfstate -lock=false -auto-approve
  cp config.tf.new config.tf
  terraform init -force-copy
  terraform plan
  terraform apply -auto-approve
fi
