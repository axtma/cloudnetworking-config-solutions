# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "description" {
  description = "Optional default description used for resources."
  type        = string
  default     = "Terraform managed Internal Passthrough Network Load Balancer."
}

variable "labels" {
  description = "Default labels to set on resources."
  type        = map(string)
  default     = {}
}

variable "source_tags" {
  description = "Default list of source tags for firewall rules."
  type        = list(string)
  default     = [""]
}

variable "target_tags" {
  description = "Default list of target tags for firewall rules."
  type        = list(string)
  default     = [""]
}

variable "is_mirroring_collector" {
  description = "Default value for designating the LB as a mirroring collector."
  type        = bool
  default     = false
}

variable "backend_service_session_affinity" {
  description = "Default session affinity for the backend service."
  type        = string
  default     = "NONE"
}

variable "backend_service_connection_draining_timeout_sec" {
  description = "Default time in seconds to wait for connections to terminate before removing a backend instance."
  type        = number
  default     = 0
}

variable "backend_log_sample_rate" {
  description = "Default backend service log sample rate (0.0 to 1.0)."
  type        = number
  default     = 1.0
}

variable "backend_log_config_enable" {
  description = "Default setting for enabling backend service logging."
  type        = bool
  default     = true
}

variable "health_check_check_interval_sec" {
  description = "Default health check interval in seconds."
  type        = number
  default     = 5
}

variable "health_check_timeout_sec" {
  description = "Default health check timeout in seconds."
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Default number of consecutive successful health checks for a backend to be considered healthy."
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Default number of consecutive failed health checks for a backend to be considered unhealthy."
  type        = number
  default     = 2
}

variable "health_check_enable_log" {
  description = "Default for enabling health check logging."
  type        = bool
  default     = false
}

variable "health_check_name_override" {
  description = "Default value for health_check.name if an existing health check name is not provided in the YAML. Should be null."
  type        = string
  default     = null
}

variable "firewall_enable_logging" {
  description = "Default for enabling firewall rule logging."
  type        = bool
  default     = false
}

variable "create_backend_firewall" {
  description = "Controls if firewall rules for the backends will be created by the module."
  type        = bool
  default     = false
}

variable "create_health_check_firewall" {
  description = "Set to false to prevent the module from creating its own firewall rules for the health check."
  type        = bool
  default     = false
}

variable "health_check_tcp_port" {
  description = "Default port for auto-created TCP health checks."
  type        = number
  default     = 80
}

variable "health_check_type" {
  description = "Default health check type (eg. http, https, tcp)."
  type        = string
  default     = "http"
}

variable "health_check_port" {
  description = "Default port for health checks."
  type        = number
  default     = 80
}

variable "health_check_tcp_port_specification" {
  description = "Default port specification for auto-created TCP health checks (USE_FIXED_PORT, USE_NAMED_PORT, USE_SERVING_PORT)."
  type        = string
  default     = "USE_SERVING_PORT"
}

variable "health_check_tcp_request" {
  description = "Default request string for auto-created TCP health checks. Should be null to use provider default."
  type        = string
  default     = null
  nullable    = true
}

variable "health_check_tcp_response" {
  description = "Default expected response string for auto-created TCP health checks. Should be null to use provider default."
  type        = string
  default     = null
  nullable    = true
}

variable "hc_grpc_config" {
  description = "Default value for the health check's GRPC configuration if not specified. Must be null."
  type        = any
  default     = null
}

variable "hc_http_config" {
  description = "Default value for the health check's HTTP configuration if not specified. Must be null."
  type        = any
  default     = null
}

variable "hc_http2_config" {
  description = "Default value for the health check's HTTP2 configuration if not specified. Must be null."
  type        = any
  default     = null
}

variable "hc_https_config" {
  description = "Default value for the health check's HTTPS configuration if not specified. Must be null."
  type        = any
  default     = null
}

variable "hc_ssl_config" {
  description = "Default value for the health check's SSL configuration if not specified. Must be null."
  type        = any
  default     = null
}

variable "hc_tcp_config" {
  description = "Default value for the health check's TCP configuration if not specified and not applying the global default. Must be null."
  type        = any
  default     = null
}

variable "forwarding_rule_protocol" {
  description = "Default protocol for the forwarding rule. Must be TCP or UDP."
  type        = string
  default     = "TCP"
}

variable "forwarding_rule_ports" {
  description = "Default list of ports for the forwarding rule."
  type        = list(string)
  default     = ["80"]
}

variable "forwarding_rule_address" {
  description = "Default IP address for the forwarding rule. Set to null for an ephemeral IP."
  type        = string
  default     = null
  nullable    = true
}

variable "forwarding_rule_global_access" {
  description = "Default setting for enabling global access on the forwarding rule."
  type        = bool
  default     = false
}

variable "backend_group_self_link_format" {
  description = "Format string used to construct the backend instance group self_link."
  type        = string
  default     = "projects/%s/regions/%s/instanceGroups/%s"
}

variable "backend_item_description" {
  description = "Default description for a backend item if not specified in YAML."
  type        = string
  default     = "Terraform managed backend group association."
}

variable "config_folder_path" {
  description = "Location of YAML files holding Internal Passthrough Network Load Balancer configuration values."
  type        = string
  default     = "../../../../../configuration/consumer-load-balancing/Network/Passthrough/Internal/config/"
}