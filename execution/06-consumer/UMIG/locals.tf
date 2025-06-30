# Copyright 2025 Google LLC
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

locals {
  config_folder_path = var.config_folder_path
  umig_configs = [
    for file in fileset(local.config_folder_path, "[^_]*.yaml") :
    yamldecode(file("${local.config_folder_path}/${file}"))
  ]

  umig_map = {
    for idx, umig in local.umig_configs : "umig-${idx}" => {
      project_id  = umig.project_id
      zone        = umig.zone
      name        = umig.name
      description = umig.description
      network     = "https://www.googleapis.com/compute/v1/projects/${umig.project_id}/global/networks/${umig.network}"
      named_ports = {
        for np in try(umig.named_ports, var.named_ports) : np.name => np.port
      }
      instances = try([
        for inst in umig.instances : inst.name
      ], [])
    }
  }
}