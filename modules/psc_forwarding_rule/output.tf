# Copyright 2024-2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Outputs the self-links of the forwarding rules created for each service attachment. 
# The map uses the SQL instance names as keys and the self-links as values.

output "forwarding_rule_self_link" {
  value       = { for k, v in google_compute_forwarding_rule.psc_forwarding_rule : k => v.self_link }
  description = "Map of created forwarding rule self-links, keyed by endpoint index."
}

# Outputs the self-links of the addresses created for each service attachment where a static IP is specified. 
# The map uses the SQL instance names as keys and the self-links as values.
output "address_self_link" {
  value       = { for k, v in google_compute_address.psc_address : k => v.self_link }
  description = "Map of created address self-links (for static IPs), keyed by endpoint index."
}

# Outputs the IP addresses of the addresses created for each service attachment where a static IP is specified. 
# The map uses the SQL instance names as keys and the IP addresses as values.
output "ip_address_literal" {
  value       = { for k, v in google_compute_address.psc_address : k => v.address }
  description = "Map of created address IP literals (for static IPs), keyed by endpoint index."
}

output "forwarding_rule_target" {
  description = "Map of forwarding rule targets, keyed by endpoint index"
  value = {
    for idx, config in var.psc_endpoints :
    idx => local.forwarding_rule_targets[idx]
  }
}