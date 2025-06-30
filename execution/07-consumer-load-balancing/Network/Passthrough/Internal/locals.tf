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

locals {
  # Read all YAML files in the specified config folder
  lb_configs_raw = [
    for file in fileset(var.config_folder_path, "[^_]*.yaml") :
    yamldecode(file("${var.config_folder_path}/${file}"))
  ]

  # Process raw YAML into the final map to be passed to the module.
  lb_map = {
    for config in local.lb_configs_raw : config.name => {
      project                         = config.project
      region                          = config.region
      name                            = config.name
      network                         = config.network
      subnetwork                      = config.subnetwork
      labels                          = try(config.labels, var.labels)
      source_tags                     = try(config.source_tags, var.source_tags)
      target_tags                     = try(config.target_tags, var.target_tags)
      is_mirroring_collector          = try(config.is_mirroring_collector, var.is_mirroring_collector)
      create_backend_firewall         = try(config.create_backend_firewall, var.create_backend_firewall),
      create_health_check_firewall    = try(config.create_health_check_firewall, var.create_health_check_firewall),
      session_affinity                = try(config.session_affinity, var.backend_service_session_affinity)
      connection_draining_timeout_sec = try(config.connection_draining_timeout_sec, var.backend_service_connection_draining_timeout_sec)
      firewall_enable_logging         = try(config.firewall_enable_logging, var.firewall_enable_logging)
      global_access                   = try(config.forwarding_rule.global_access, var.forwarding_rule_global_access)
      ip_address                      = try(config.forwarding_rule.address, var.forwarding_rule_address)
      ip_protocol                     = try(config.forwarding_rule.protocol, var.forwarding_rule_protocol)
      ports                           = try(config.forwarding_rule.ports, var.forwarding_rule_ports)
      backends = [
        for backend_def in try(config.backends, []) : {
          group = (
            try(backend_def.group_zone, null) != null ?
            format("projects/%s/zones/%s/instanceGroups/%s",
              config.project,
              backend_def.group_zone,
              backend_def.group_name
            ) :
            format(var.backend_group_self_link_format,
              config.project,
              try(backend_def.group_region, config.region),
              backend_def.group_name
            )
          )
        }
      ]
      health_check = {
        type                = try(config.health_check.type, var.health_check_type)
        check_interval_sec  = try(config.health_check.check_interval_sec, var.health_check_check_interval_sec)
        healthy_threshold   = try(config.health_check.healthy_threshold, var.health_check_healthy_threshold)
        timeout_sec         = try(config.health_check.timeout_sec, var.health_check_timeout_sec)
        unhealthy_threshold = try(config.health_check.unhealthy_threshold, var.health_check_unhealthy_threshold)
        port                = try(config.health_check.port, var.health_check_port)
        request_path        = try(config.health_check.request_path, "/")
        enable_log          = try(config.health_check.enable_log, var.health_check_enable_log)
      }
    }
  }
}