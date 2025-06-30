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

module "internal_passthrough_nlb" {
  for_each                        = local.lb_map
  source                          = "GoogleCloudPlatform/lb-internal/google"
  version                         = "7.0.0"
  project                         = each.value.project
  region                          = each.value.region
  name                            = each.value.name
  source_tags                     = each.value.source_tags
  target_tags                     = each.value.target_tags
  network                         = each.value.network
  subnetwork                      = each.value.subnetwork
  backends                        = each.value.backends
  health_check                    = each.value.health_check
  ip_protocol                     = each.value.ip_protocol
  ports                           = each.value.ports
  ip_address                      = each.value.ip_address
  global_access                   = each.value.global_access
  is_mirroring_collector          = each.value.is_mirroring_collector
  labels                          = each.value.labels
  session_affinity                = each.value.session_affinity
  connection_draining_timeout_sec = each.value.connection_draining_timeout_sec
  firewall_enable_logging         = each.value.firewall_enable_logging
  create_backend_firewall         = each.value.create_backend_firewall
  create_health_check_firewall    = each.value.create_health_check_firewall
}