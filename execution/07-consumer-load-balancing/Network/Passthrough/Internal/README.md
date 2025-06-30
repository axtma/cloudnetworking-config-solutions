# Consumer Networking - Internal Passthrough Network Load Balancing

## Overview

This Terraform solution is designed specifically for deploying and managing **Internal Passthrough Network Load Balancers** on Google Cloud. It provides a flexible way to define multiple ILBs using YAML configuration files, enabling a highly available and scalable architecture for distributing TCP/UDP traffic from clients *within your VPC network*.

Internal Passthrough Network Load Balancers are **regional, non-proxied load balancers** that forward packets directly from internal clients to backend instances, preserving the client's source IP address. They operate at Layer 4 and are ideal for internal microservices, multi-tier applications, and as collectors for features like [Packet Mirroring](https://cloud.google.com/vpc/docs/packet-mirroring).

  * [Learn more about Internal Passthrough Network Load Balancing](https://cloud.google.com/load-balancing/docs/internal)

## Pre-Requisites

Ensure the following are in place before deploying:

### Prior Step Completion:

Successful deployment typically assumes the completion of foundational infrastructure stages and the creation of backend resources:

  * **01-organization:** Handles organization-level setup and **enables necessary Google Cloud APIs** for the project.
  * **02-networking:** Establishes core network infrastructure like **VPC networks** and **subnetworks**. The Internal Load Balancer and its backends will reside within these resources.
      * [VPC Networks documentation](https://cloud.google.com/vpc/docs/vpc)
      * [Subnetworks documentation](https://cloud.google.com/vpc/docs/subnets)
  * **Backend Instance Groups:** You **must** have backend instance groups already created. This solution supports:
    * [Managed Instance Groups (MIGs)](https://cloud.google.com/compute/docs/instance-groups/using-managed-groups)
    * [Unmanaged Instance Groups](https://cloud.google.com/compute/docs/instance-groups/creating-groups-of-unmanaged-instances)

### Enabled APIs:

Ensure the following Google Cloud APIs are enabled in your project (usually handled by the organization stage):

  * `compute.googleapis.com` (Compute Engine API)
      * [Enabling APIs](https://cloud.google.com/apis/docs/getting-started#enabling_apis)

### Permissions:

The Identity and Access Management (IAM) principal (user account or service account) executing Terraform must have sufficient permissions in the target project. The following pre-defined role (or a custom role with equivalent permissions) is typically required:

  * `roles/compute.loadBalancerAdmin`: For creating, updating, and deleting Load Balancing resources (Backend Services, Forwarding Rules, Health Checks).

Alternatively, you can create a custom role with the specific `get`, `list`, and `use` permissions for `compute.instanceGroups` and `compute.subnetworks`, combined with the full permissions from `roles/compute.loadBalancerAdmin`.

  * [Understanding IAM roles and permissions](https://cloud.google.com/iam/docs/understanding-roles)
  * [Compute Engine IAM roles](https://cloud.google.com/compute/docs/access/iam)

## Execution Steps

1.  **Configuration:**

      * Navigate to the directory containing this solution's Terraform configuration (`lb.tf`, `variables.tf`, `locals.tf`, etc.).
      * Locate the directory specified by the `config_folder_path` variable (`default: "../../../../../configuration/consumer-load-balancing/Network/Passthrough/Internal/config/"`).
      * Create or modify YAML configuration files (e.g., `internal-lb-lite.yaml`) within this folder. Each YAML file should define the configuration for one load balancer instance.
      * Define your desired Internal Load Balancer configurations in these YAML files. Refer to the **Examples** section below and the `variables.tf` file for the expected structure and available options. **Ensure that required fields like `name`, `project_id`, `region`, `network`, `subnetwork`, and `backends` are correctly specified.**

2.  **Terraform Initialization:**

      * Open your terminal in this solution's root directory.

      * Initialize Terraform to download the required provider plugins and modules:

        ```bash
        terraform init
        ```

      * [Terraform `init` documentation](https://www.google.com/search?q=%5Bhttps://developer.hashicorp.com/terraform/cli/commands/init%5D\(https://developer.hashicorp.com/terraform/cli/commands/init\))

3.  **Review the Execution Plan:**

      * Generate and review an execution plan to understand what Terraform will create, modify, or destroy:

        ```bash
        terraform plan --var-file=../../../../../configuration/consumer-load-balancing/Network/Passthrough/Internal/internal-network-passthrough.tfvars
        ```

      * Carefully review the planned actions, especially the creation of backend services and forwarding rules, verifying names, regions, and network settings.

      * [Terraform `plan` documentation](https://www.google.com/search?q=%5Bhttps://developer.hashicorp.com/terraform/cli/commands/plan%5D\(https://developer.hashicorp.com/terraform/cli/commands/plan\))

4.  **Apply the Configuration:**

      * If the plan is satisfactory, apply the configuration to provision the resources:

        ```bash
        terraform apply --var-file=../../../../../configuration/consumer-load-balancing/Network/Passthrough/Internal/internal-network-passthrough.tfvars
        ```

      * [Terraform `apply` documentation](https://www.google.com/search?q=%5Bhttps://developer.hashicorp.com/terraform/cli/commands/apply%5D\(https://developer.hashicorp.com/terraform/cli/commands/apply\))

5.  **Monitor and Manage:**

      * After applying, monitor the status of your load balancers, including **backend health status**, through the [Google Cloud Console Load Balancing section](https://console.cloud.google.com/networking/loadbalancing/list).
      * Use `gcloud compute` commands to get details about your load balancers, backend services, and health checks.
          * [gcloud compute forwarding-rules reference](https://cloud.google.com/sdk/gcloud/reference/compute/forwarding-rules)
          * [gcloud compute backend-services reference](https://cloud.google.com/sdk/gcloud/reference/compute/backend-services)
          * [gcloud compute health-checks reference](https://cloud.google.com/sdk/gcloud/reference/compute/health-checks)
      * Update your load balancer configurations by modifying the corresponding YAML files in the `config_folder_path` and re-running `terraform apply`.

## Examples

The `locals.tf` file processes YAML files from the `config_folder_path`. Each YAML file defines the configuration for a single load balancer instance.

Below are sample YAML structures based on your requirements, demonstrating common configurations. Refer to this solution's `variables.tf` file for the full list of default values and configurable options.

  * **Basic ILB (Lite):**

    This example defines a simple TCP ILB targeting an existing Regional Managed Instance Group (MIG). It relies on defaults for the health check and forwarding rule. Since `group_region` is omitted, the MIG is assumed to be in the same region as the load balancer (`us-central1`).

    ```yaml
    name: internal-lb-lite
    project_id: gcp-project-id
    region: us-central1
    network: vpc-name
    subnetwork: subnet-name
    source_tags: ["allow-all-internal"]
    target_tags: ["web-server-backend"]
    backends:
      - group_name: regional-mig-in-us-central1
    ```

  * **ILB as a Packet Mirroring Collector:**

    This example shows how to designate an ILB as a valid destination for Packet Mirroring. The `is_mirroring_collector` flag is the key setting. This allows a separate `google_compute_packet_mirroring` resource (defined in another stage) to target this ILB's forwarding rule.

    ```yaml
    name: packet-mirroring-collector
    project_id: gcp-project-id
    region: us-central1
    network: vpc-name
    subnetwork: collector-subnet
    is_mirroring_collector: true # Designate this LB as a collector
    source_tags: ["allow-health-checks"]
    target_tags: ["ids-appliance-backend"]
    backends:
      - group_name: security-appliance-mig
    ```

  * **Expanded ILB with Advanced Options:**

    This example demonstrates defining a more complex ILB with a static internal IP, global access for clients in other regions, and specific backend service and health check parameters. It also shows a mix of regional and zonal backends.

    ```yaml
    name: internal-lb-expanded
    project_id: gcp-project-id
    region: us-east1
    network: vpc-name
    subnetwork: prod-subnet-useast1
    source_tags: ["allow-all-internal"]
    target_tags: ["app-server-prod"]
    labels:
      env: production
      owner: networking-team

    # Custom backend service settings
    session_affinity: CLIENT_IP
    connection_draining_timeout_sec: 60

    # Mixed regional and zonal backends
    backends:
      - group_name: primary-mig-us-east1
        description: "Primary backend instance group"
      - group_name: secondary-zonal-ig
        group_zone: us-east1-b
        description: "Secondary zonal instance group"

    # Custom health check object
    health_check:
      type: http
      check_interval_sec: 10
      timeout_sec: 8
      healthy_threshold: 3
      unhealthy_threshold: 4
      enable_log: true
      port: 8080
      request_path: /healthz

    # Custom forwarding rule settings
    forwarding_rule:
      protocol: TCP
      ports: ["80", "443"]
      address: 10.10.20.5 # A pre-reserved static internal IP
      global_access: true # Allow clients from other regions in the VPC
    ```

<!-- BEGIN_TF_DOCS -->

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_internal_passthrough_nlb"></a> [internal\_passthrough\_nlb](#module\_internal\_passthrough\_nlb) | GoogleCloudPlatform/lb-internal/google | 7.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_group_self_link_format"></a> [backend\_group\_self\_link\_format](#input\_backend\_group\_self\_link\_format) | Format string used to construct the backend instance group self\_link. | `string` | `"projects/%s/regions/%s/instanceGroups/%s"` | no |
| <a name="input_backend_item_description"></a> [backend\_item\_description](#input\_backend\_item\_description) | Default description for a backend item if not specified in YAML. | `string` | `"Terraform managed backend group association."` | no |
| <a name="input_backend_log_config_enable"></a> [backend\_log\_config\_enable](#input\_backend\_log\_config\_enable) | Default setting for enabling backend service logging. | `bool` | `true` | no |
| <a name="input_backend_log_sample_rate"></a> [backend\_log\_sample\_rate](#input\_backend\_log\_sample\_rate) | Default backend service log sample rate (0.0 to 1.0). | `number` | `1` | no |
| <a name="input_backend_service_connection_draining_timeout_sec"></a> [backend\_service\_connection\_draining\_timeout\_sec](#input\_backend\_service\_connection\_draining\_timeout\_sec) | Default time in seconds to wait for connections to terminate before removing a backend instance. | `number` | `0` | no |
| <a name="input_backend_service_session_affinity"></a> [backend\_service\_session\_affinity](#input\_backend\_service\_session\_affinity) | Default session affinity for the backend service. | `string` | `"NONE"` | no |
| <a name="input_config_folder_path"></a> [config\_folder\_path](#input\_config\_folder\_path) | Location of YAML files holding Internal Passthrough Network Load Balancer configuration values. | `string` | `"../../../../../configuration/consumer-load-balancing/Network/Passthrough/Internal/config/"` | no |
| <a name="input_create_backend_firewall"></a> [create\_backend\_firewall](#input\_create\_backend\_firewall) | Controls if firewall rules for the backends will be created by the module. | `bool` | `false` | no |
| <a name="input_create_health_check_firewall"></a> [create\_health\_check\_firewall](#input\_create\_health\_check\_firewall) | Set to false to prevent the module from creating its own firewall rules for the health check. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Optional default description used for resources. | `string` | `"Terraform managed Internal Passthrough Network Load Balancer."` | no |
| <a name="input_firewall_enable_logging"></a> [firewall\_enable\_logging](#input\_firewall\_enable\_logging) | Default for enabling firewall rule logging. | `bool` | `false` | no |
| <a name="input_forwarding_rule_address"></a> [forwarding\_rule\_address](#input\_forwarding\_rule\_address) | Default IP address for the forwarding rule. Set to null for an ephemeral IP. | `string` | `null` | no |
| <a name="input_forwarding_rule_global_access"></a> [forwarding\_rule\_global\_access](#input\_forwarding\_rule\_global\_access) | Default setting for enabling global access on the forwarding rule. | `bool` | `false` | no |
| <a name="input_forwarding_rule_ports"></a> [forwarding\_rule\_ports](#input\_forwarding\_rule\_ports) | Default list of ports for the forwarding rule. | `list(string)` | <pre>[<br>  "80"<br>]</pre> | no |
| <a name="input_forwarding_rule_protocol"></a> [forwarding\_rule\_protocol](#input\_forwarding\_rule\_protocol) | Default protocol for the forwarding rule. Must be TCP or UDP. | `string` | `"TCP"` | no |
| <a name="input_hc_grpc_config"></a> [hc\_grpc\_config](#input\_hc\_grpc\_config) | Default value for the health check's GRPC configuration if not specified. Must be null. | `any` | `null` | no |
| <a name="input_hc_http2_config"></a> [hc\_http2\_config](#input\_hc\_http2\_config) | Default value for the health check's HTTP2 configuration if not specified. Must be null. | `any` | `null` | no |
| <a name="input_hc_http_config"></a> [hc\_http\_config](#input\_hc\_http\_config) | Default value for the health check's HTTP configuration if not specified. Must be null. | `any` | `null` | no |
| <a name="input_hc_https_config"></a> [hc\_https\_config](#input\_hc\_https\_config) | Default value for the health check's HTTPS configuration if not specified. Must be null. | `any` | `null` | no |
| <a name="input_hc_ssl_config"></a> [hc\_ssl\_config](#input\_hc\_ssl\_config) | Default value for the health check's SSL configuration if not specified. Must be null. | `any` | `null` | no |
| <a name="input_hc_tcp_config"></a> [hc\_tcp\_config](#input\_hc\_tcp\_config) | Default value for the health check's TCP configuration if not specified and not applying the global default. Must be null. | `any` | `null` | no |
| <a name="input_health_check_check_interval_sec"></a> [health\_check\_check\_interval\_sec](#input\_health\_check\_check\_interval\_sec) | Default health check interval in seconds. | `number` | `5` | no |
| <a name="input_health_check_enable_log"></a> [health\_check\_enable\_log](#input\_health\_check\_enable\_log) | Default for enabling health check logging. | `bool` | `false` | no |
| <a name="input_health_check_healthy_threshold"></a> [health\_check\_healthy\_threshold](#input\_health\_check\_healthy\_threshold) | Default number of consecutive successful health checks for a backend to be considered healthy. | `number` | `2` | no |
| <a name="input_health_check_name_override"></a> [health\_check\_name\_override](#input\_health\_check\_name\_override) | Default value for health\_check.name if an existing health check name is not provided in the YAML. Should be null. | `string` | `null` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | Default port for health checks. | `number` | `80` | no |
| <a name="input_health_check_tcp_port"></a> [health\_check\_tcp\_port](#input\_health\_check\_tcp\_port) | Default port for auto-created TCP health checks. | `number` | `80` | no |
| <a name="input_health_check_tcp_port_specification"></a> [health\_check\_tcp\_port\_specification](#input\_health\_check\_tcp\_port\_specification) | Default port specification for auto-created TCP health checks (USE\_FIXED\_PORT, USE\_NAMED\_PORT, USE\_SERVING\_PORT). | `string` | `"USE_SERVING_PORT"` | no |
| <a name="input_health_check_tcp_request"></a> [health\_check\_tcp\_request](#input\_health\_check\_tcp\_request) | Default request string for auto-created TCP health checks. Should be null to use provider default. | `string` | `null` | no |
| <a name="input_health_check_tcp_response"></a> [health\_check\_tcp\_response](#input\_health\_check\_tcp\_response) | Default expected response string for auto-created TCP health checks. Should be null to use provider default. | `string` | `null` | no |
| <a name="input_health_check_timeout_sec"></a> [health\_check\_timeout\_sec](#input\_health\_check\_timeout\_sec) | Default health check timeout in seconds. | `number` | `5` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | Default health check type (eg. http, https, tcp). | `string` | `"http"` | no |
| <a name="input_health_check_unhealthy_threshold"></a> [health\_check\_unhealthy\_threshold](#input\_health\_check\_unhealthy\_threshold) | Default number of consecutive failed health checks for a backend to be considered unhealthy. | `number` | `2` | no |
| <a name="input_is_mirroring_collector"></a> [is\_mirroring\_collector](#input\_is\_mirroring\_collector) | Default value for designating the LB as a mirroring collector. | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Default labels to set on resources. | `map(string)` | `{}` | no |
| <a name="input_source_tags"></a> [source\_tags](#input\_source\_tags) | Default list of source tags for firewall rules. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_target_tags"></a> [target\_tags](#input\_target\_tags) | Default list of target tags for firewall rules. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ilb_forwarding_rule_addresses"></a> [ilb\_forwarding\_rule\_addresses](#output\_ilb\_forwarding\_rule\_addresses) | Map of Internal Passthrough Network Load Balancer names to their assigned internal IP addresses. |
| <a name="output_ilb_forwarding_rules"></a> [ilb\_forwarding\_rules](#output\_ilb\_forwarding\_rules) | Map of Internal Passthrough Network Load Balancer names to their forwarding rule self\_links. |

<!-- END_TF_DOCS -->