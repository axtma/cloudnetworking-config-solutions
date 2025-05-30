/**
 * Copyright 2024-2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# The self-links of the forwarding rules created for each service attachment.
# This map uses the SQL instance names as keys and the self-links as values.
output "forwarding_rule_self_link" {
  value       = module.psc_forwarding_rule.forwarding_rule_self_link
  description = "Map of created forwarding rule self-links, keyed by endpoint index."
}

# Outputs the self-links of the addresses created for each service attachment where a static IP is specified. 
# The map uses the SQL instance names as keys and the self-links as values.
output "address_self_link" {
  value       = module.psc_forwarding_rule.address_self_link
  description = "Map of created address self-links (for static IPs), keyed by endpoint index."
}

# Outputs the IP addresses of the addresses created for each service attachment where a static IP is specified. 
# The map uses the SQL instance names as keys and the IP addresses as values.
output "ip_address_literal" {
  value       = module.psc_forwarding_rule.ip_address_literal
  description = "Map of created address IP literals (for static IPs), keyed by endpoint index."
}

output "forwarding_rule_target" {
  value       = module.psc_forwarding_rule.forwarding_rule_target
  description = "Map of forwarding rule targets, keyed by endpoint index"
}
