# Unmanaged Instance Groups (UMIG)

## Overview

This Terraform solution provides a modular approach to grouping pre-existing Google Compute Engine VM instances into Unmanaged Instance Groups (UMIGs) using a custom Terraform module. Unmanaged Instance Groups allow you to organize and manage collections of VMs for load balancing or other purposes, without enforcing uniformity or auto-healing.

The solution uses a modular design, with the `umig.tf` file defining a Terraform module that leverages a custom `umig` module. This module encapsulates the logic for creating UMIGs based on parameters specified in a local map, which is populated from YAML configuration files.

## Pre-Requisites

### Prior Step Completion

- **Completed Prior Stages:** Successful deployment of UMIG resources depends on the completion of the following stages:
    - **01-organization:** Activation of required Google Cloud APIs for UMIG.
    - **02-networking:** Setup of necessary network infrastructure, including VPCs and subnets, to support VM connectivity.
    - **03-security:** Configuration of firewall rules to allow access to UMIG instances on appropriate ports and IP ranges.
    - **VM Creation:** The VMs you wish to group must already exist in your project. You can create these VMs in earlier stages, or within the 06-consumer/GCE stage itself using the GCE substage provided in this solution.
    - As a consumer, this UMIG solution enables you to organize and manage your existing VM instances into logical groups for purposes such as load balancing, simplified monitoring, or streamlined operational tasks, without enforcing uniformity or automated instance management.
### Enabled APIs

Ensure the following Google Cloud APIs are enabled in your project:

- Compute Engine API

### Permissions

The user or service account executing Terraform must have the following roles (or equivalent permissions):

- Compute Admin (for managing instance groups)
- Service Account User (if using service accounts)

## Execution Steps

1. **Configuration:**

    - Define your YAML configurations for each unmanaged instance group.
    - Place them in the `configuration/consumer/UMIG/config` folder.

2. **Terraform Initialization:**

    - Open your terminal and navigate to the directory containing your Terraform configuration.
    - Run the following command to initialize Terraform:

    ```bash
    terraform init
    ```

3. **Review the Execution Plan:**

    - Use the following command to generate an execution plan. This will show you the changes Terraform will make to your Google Cloud infrastructure:

    ```bash
    terraform plan --var-file=../../../configuration/consumer/UMIG/config/umig.tfavrs
    ```

    Carefully review the plan to ensure it aligns with your intended configuration.

4. **Apply the Configuration:**

    Once you're satisfied with the plan, execute the following command to provision your Unmanaged Instance Groups:

    ```bash
    terraform apply --var-file=../../../configuration/consumer/UMIG/config/umig.tfavrs
    ```

    Terraform will create the corresponding UMIGs in your Google Cloud project based on your configurations.

5. **Monitor and Manage:**

    After the instance groups are created, you can monitor their status and manage group membership through the Google Cloud Console or using the Google Cloud CLI. Use Terraform to manage updates and changes to your Unmanaged Instance Groups as needed.

## Important Notes

- This solution assumes that all required VM instances already exist in your project as per previous steps.
- Ensure that you provide correct service account credentials (if applicable) to allow Terraform to interact with your Google Cloud project.
- Refer to the `variables.tf` file for a complete list of available variables and their descriptions.
- The custom UMIG module used in this solution is designed for grouping existing VMs only. It does not create new VM instances.

## Examples

### Sample YAML
Here is a generic example of an `instance.yaml` for UMIG:

```yaml
project_id: your_project_id
zone: your_zone                # The zone where your instances are located (e.g., us-central1-a)
name: your_umig_name           # The name you want to assign to this unmanaged instance group
description: "Instance group managed by the UMIG Terraform module."
network: your_network_name
instances:
    - instance_name_1
    - instance_name_2
named_ports:
    - name: http
        port: 80
    - name: https
        port: 443
```
Replace the placeholder values (e.g., `<your-project-id>`, `<your-zone>`, `<instance-1>`) with your actual project, zone, and instance details.

<!-- BEGIN_TF_DOCS -->
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_umig"></a> [umig](#module\_umig) | ../../../modules/umig | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_folder_path"></a> [config\_folder\_path](#input\_config\_folder\_path) | Path to the folder containing UMIG YAML config files. | `string` | `"../../../configuration/consumer/UMIG/config"` | no |
| <a name="input_named_ports"></a> [named\_ports](#input\_named\_ports) | List of named ports with name and port attributes. | <pre>list(object({<br/>    name = string<br/>    port = number<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "http",<br/>    "port": 80<br/>  },<br/>  {<br/>    "name": "https",<br/>    "port": 443<br/>  }<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_umig_instances"></a> [umig\_instances](#output\_umig\_instances) | Instances in each Unmanaged Instance Group |
| <a name="output_umig_self_links"></a> [umig\_self\_links](#output\_umig\_self\_links) | Self-links for Unmanaged Instance Groups |
<!-- END_TF_DOCS -->