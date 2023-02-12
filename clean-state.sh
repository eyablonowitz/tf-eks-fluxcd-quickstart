#!/bin/sh

rm -f *.tfstate
rm -f modules/bootstrap/*.tfstate
rm -Rf .terraform
rm -Rf modules/bootstrap/.terraform
rm -f .terraform.lock.hcl
rm -f modules/bootstrap/.terraform.lock.hcl
