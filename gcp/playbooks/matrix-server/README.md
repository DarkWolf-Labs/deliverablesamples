# Matrix Server on GCP

## Description

This containerized deployment is based off of the deployment instructions found on https://matrix.org/ and https://github.com/matrix-org/synapse/blob/develop/contrib/docker/docker-compose.yml

## Capabilities

This blueprint deploys a Matrix server with the following configuration

* Instances running the latest Rocky Linux
~* A highly-available CloudSQL instance (w/o PostGIS extension enabled, instructions here https://cloud.google.com/sql/docs/postgres/extensions)~ (We would normally deploy this in a production ready way, but we want to demonstrate how we would use docker-compose to deploy things quickly)
* Pull through proxy Artifact Registry to get access to Registry1 for hardened containers
* The latest Matrix Synapse server deployed using hardened container from Registry1

## Variables

| Variable Name | Description | Data Type | Default Value | Validation |
|---|---|---|---|---|
 | region | GCP Region to deploy into | string | us-east4 | Must be a valid GCP region (us-central1, us-central2, etc.) |
 | prefix | Prefix used for resource names | string | | Must have between 2 and 5 alphanumeric characters |
 | project_create | Provide values if project creation is needed | object | null | Parent format: folders/folder_id or organizations/org_id |
| project_id | Project id references existing project | string | | |
| vpc_config | Shared VPC network configurations to use | object | null |
| service_encryption_keys | Cloud KMS to use for encryption | object | null |
| registry_username | Username for Registry1 | string | | |
| registry_password_secret | Secret name for Registry1 password | string | | |
| instance_type | Instance type for Matrix server | string | n2-standard-2 | Valid GCP instance class |
| server_name | FQDN for your matrix server | string | Follows standard FQDN format |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| server_ip | Internal IP of the Matrix Synapse server, suitable for accessing via an OpenVPN instance inside the VPC |  false |