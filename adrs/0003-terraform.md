# 4. Terraform

Date: 2019-09-30

## Status

Accepted

## Context

We need to decide how to keep the infrastructure as code.

## Decision

We are going to use terraform as is well compatible with AWS and covers
almost all services and also if we needed to move to another cloud
provider might be compatible. In addition we are going to use
terraform.io to deploy the infrastructure.

## Consequences

All infrastructure code must be in here with no exceptions.
