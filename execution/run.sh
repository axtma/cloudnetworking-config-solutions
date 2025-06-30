#!/bin/bash
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

set -eo pipefail  # Exit on error or pipe failure
# Initialize default values for the flags/variables
stage=""
tfcommand="init"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Define valid stages to be accepted by the -s flag
valid_stages="all organization networking networking/ncc security/firewall/firewallpolicy security/certificates/compute-ssl-certs/google-managed security/alloydb security/mrc security/cloudsql security/gce security/mig security/workbench producer/alloydb producer/mrc producer/cloudsql producer/gke producer/vectorsearch producer/onlineendpoint producer-connectivity consumer/gce consumer/serverless/cloudrun/job consumer/serverless/cloudrun/service consumer/serverless/appengine/standard consumer/serverless/appengine/flexible consumer/mig consumer/workbench consumer/umig load-balancing/application/external load-balancing/network/passthrough/external load-balancing/network/passthrough/external"

# Define valid Terraform commands to be accepted by the -tf or --tfcommand flag
valid_tf_commands="init apply apply-auto-approve destroy destroy-auto-approve init-apply init-apply-auto-approve"

# Define stage to path mapping (excluding "all")
stage_path_map=(
    "organization=01-organization"
    "networking=02-networking"
    "networking/ncc=02-networking/NCC"
    "security/firewall/firewallpolicy=03-security/Firewall/FirewallPolicy"
    "security/certificates/compute-ssl-certs/google-managed=03-security/Certificates/Compute-SSL-Certs/Google-Managed"
    "security/alloydb=03-security/AlloyDB"
    "security/mrc=03-security/MRC"
    "security/cloudsql=03-security/CloudSQL"
    "security/gce=03-security/GCE"
    "security/mig=03-security/MIG"
    "security/workbench=03-security/Workbench"
    "producer/alloydb=04-producer/AlloyDB"
    "producer/mrc=04-producer/MRC"
    "producer/cloudsql=04-producer/CloudSQL"
    "producer/gke=04-producer/GKE"
    "producer/vectorsearch=04-producer/VectorSearch"
    "producer/onlineendpoint=04-producer/Vertex-AI-Online-Endpoints"
    "producer-connectivity=05-producer-connectivity"
    "consumer/gce=06-consumer/GCE"
    "consumer/serverless/cloudrun/job=06-consumer/Serverless/CloudRun/Job"
    "consumer/serverless/cloudrun/service=06-consumer/Serverless/CloudRun/Service"
    "consumer/serverless/appengine/standard=06-consumer/Serverless/AppEngine/Standard"
    "consumer/serverless/appengine/flexible=06-consumer/Serverless/AppEngine/Flexible"
    "consumer/mig=06-consumer/MIG"
    "consumer/workbench=06-consumer/Workbench"
    "consumer/umig=06-consumer/UMIG"
    "load-balancing/application/external=07-consumer-load-balancing/Application/External"
    "load-balancing/network/passthrough/internal=07-consumer-load-balancing/Network/Passthrough/Internal"
    "load-balancing/network/passthrough/external=07-consumer-load-balancing/Network/Passthrough/External"

)

# Define tfvars to stage path mapping (excluding "all")
stagewise_tfvar_path_map=(
    "01-organization=../../configuration/organization.tfvars"
    "02-networking=../../configuration/networking.tfvars"
    "02-networking/NCC=../../../configuration/networking/ncc/ncc.tfvars"
    "03-security/Firewall/FirewallPolicy=../../../../configuration/security/Firewall/FirewallPolicy/firewallpolicy.tfvars"
    "03-security/Certificates/Compute-SSL-Certs/Google-Managed=../../../../../configuration/security/Certificates/Compute-SSL-Certs/Google-Managed/google_managed_ssl.tfvars"
    "03-security/AlloyDB=../../../configuration/security/alloydb.tfvars"
    "03-security/MRC=../../../configuration/security/mrc.tfvars"
    "03-security/CloudSQL=../../../configuration/security/cloudsql.tfvars"
    "03-security/GCE=../../../configuration/security/gce.tfvars"
    "03-security/MIG=../../../configuration/security/mig.tfvars"
    "03-security/Workbench=../../../configuration/security/workbench.tfvars"
    "04-producer/AlloyDB=../../../configuration/producer/AlloyDB/alloydb.tfvars"
    "04-producer/MRC=../../../configuration/producer/MRC/mrc.tfvars"
    "04-producer/CloudSQL=../../../configuration/producer/CloudSQL/cloudsql.tfvars"
    "04-producer/GKE=../../../configuration/producer/GKE/gke.tfvars"
    "04-producer/VectorSearch=../../../configuration/producer/VectorSearch/vectorsearch.tfvars"
    "04-producer/Vertex-AI-Online-Endpoints=../../../configuration/producer/Vertex-AI-Online-Endpoints/vertex-ai-online-endpoints.tfvars"
    "05-producer-connectivity=../../configuration/producer-connectivity.tfvars"
    "06-consumer/GCE=../../../configuration/consumer/GCE/gce.tfvars"
    "06-consumer/Serverless/CloudRun/Job=../../../../../configuration/consumer/Serverless/CloudRun/Job/cloudrunjob.tfvars"
    "06-consumer/Serverless/CloudRun/Service=../../../../../configuration/consumer/Serverless/CloudRun/Service/cloudrunservice.tfvars"
    "06-consumer/Serverless/AppEngine/Standard=../../../../../configuration/consumer/Serverless/AppEngine/Standard/standardappengine.tfvars"
    "06-consumer/Serverless/AppEngine/Flexible=../../../../../configuration/consumer/Serverless/AppEngine/Flexible/flexibleappengine.tfvars"
    "06-consumer/MIG=../../../configuration/consumer/MIG/mig.tfvars"
    "06-consumer/Workbench=../../../configuration/consumer/Workbench/workbench.tfvars"
    "06-consumer/UMIG=../../../configuration/consumer/UMIG/umig.tfvars"
    "07-consumer-load-balancing/Application/External=../../../../configuration/consumer-load-balancing/Application/External/external-application-lb.tfvars"
    "07-consumer-load-balancing/Network/Passthrough/Internal=../../../../../configuration/consumer-load-balancing/Network/Passthrough/Internal/internal-network-passthrough.tfvars"
    "07-consumer-load-balancing/Network/Passthrough/External=../../../../../configuration/consumer-load-balancing/Network/Passthrough/External/external-network-passthrough.tfvars"
)

security_config_map=(
    "03-security/GCE=../configuration/consumer/GCE/config"
    "03-security/MRC=../configuration/producer/MRC/config"
    "03-security/CloudSQL=../configuration/producer/CloudSQL/config"
    "03-security/AlloyDB=../configuration/producer/AlloyDB/config"
    "03-security/MIG=../configuration/consumer/MIG/config"
    "03-security/Workbench=../configuration/consumer/Workbench/config"
)

# Define stage to description mapping (excluding "all")
stage_wise_description_map=(
  "all=Progresses through each stage individually."
  "organization=Executes 01-organization stage, manages Google Cloud APIs."
  "networking=Executes 02-networking stage, manages network resources."
  "networking/ncc=Executes 02-networking/NCC stage, manages NCC network resources."
  "security/firewall/firewallpolicy=03-security/Firewall/FirewallPolicy, manages firewall policies."
  "security/certificates/compute-ssl-certs/google-managed=03-security/certificates/compute-ssl-certs/google-managed, manages ssl certificates"
  "security/alloydb=Executes 03-security/AlloyDB stage, manages AlloyDB firewall rules."
  "security/mrc=Executes 03-security/MRC stage, manages MRC firewall rules."
  "security/cloudsql=Executes 03-security/CloudSQL stage, manages CloudSQL firewall rules."
  "security/gce=Executes 03-security/GCE stage, manages GCE firewall rules."
  "security/mig=Executes 03-security/MIG stage, manages MIG firewall rules."
  "security/workbench=Executes 03-security/Workbench stage, manages Workbench firewall rules."
  "producer/alloydb=Executes 04-producer/AlloyDB stage, manages AlloyDB instance."
  "producer/mrc=Executes 04-producer/MRC stage, manages MRC instance."
  "producer/cloudsql=Executes 04-producer/CloudSQL stage, manages CloudSQL instance."
  "producer/gke=Executes 04-producer/GKE stage, manages GKE clusters."
  "producer/vectorsearch=Executes 04-producer/VectorSearch stage, manages Vector Search instances."
  "producer/onlineendpoint=Executes 04-producer/Vertex-AI-Online-Endpoints stage, manages Online endpoints."
  "producer-connectivity=Executes 05-producer-connectivity stage, manages PSC for supported services."
  "consumer/gce=Executes 06-consumer/GCE stage, manages GCE instance."
  "consumer/serverless/cloudrun/job=Executes 06-consumer/Serverless/CloudRun/Job, manages Cloud Run jobs."
  "consumer/serverless/cloudrun/service=Executes 06-consumer/Serverless/CloudRun/Service, manages Cloud Run services."
  "consumer/serverless/appengine/flexible=Executes 06-consumer/Serverless/AppEngine/FlexibleAppEngine, manages Flexible App Engine"
  "consumer/serverless/appengine/standard=Executes 06-consumer/Serverless/AppEngine/StandardAppEngine, manages Standard App Engine"
  "consumer/mig=Executes 06-consumer/MIG stage, manages MIG instances."
  "consumer/workbench=Executes 06-consumer/Workbench stage, manages Workbench instance."
  "consumer/umig=Executes 06-consumer/UMIG stage, manages UMIG instances."
  "load-balancing/application/external=Executes 07-consumer-load-balancing/Application/External stage, manages External Application Load Balancers."
  "load-balancing/network/passthrough/internal=Executes 07-consumer-load-balancing/Network/Passthrough/Internal stage, manages Int Net Passthrough LBs."
  "load-balancing/network/passthrough/external=Executes 07-consumer-load-balancing/Network/Passthrough/External stage, manages Ext Net Passthrough LBs."
  )

# Define tfcommand to description mapping.
tfcommand_wise_description_map=(
    "init=Prepare your working directory for other commands."
    "apply=Create or update infrastructure."
    "apply-auto-approve=Create or Update infrastructure, skips user input."
    "destroy=Destroy previously-created infrastructure."
    "destroy-auto-approve=Destroy previously-created infrastructure, skips user input."
    "init-apply=Prepares working directory and creates/updates infrastructure."
    "init-apply-auto-approve=Prepares working directory and creates/updates infrastructure, skips user input."
)

# Function to get the value associated with a key present in the *_map variables created
function get_value {
  local key="$1"
  local map_name="$2"    # Name of the map array
  local map_ref
  eval "map_ref=(\"\${$map_name[@]}\")"

  # Iterate directly over the elements of the array
  for pair in "${map_ref[@]}"; do
    key_from_map="${pair%%=*}"       # Extract key (part before '=')
    if [[ "$key_from_map" == "$key" ]]; then
      value="${pair#*=}"
      echo "${value}"
      return
    fi
  done
}

# Function to check if any .yaml files exist in the specified directory
function check_yaml_exists {
    local dir="$1"
    if compgen -G "$dir/*.yaml" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to populate valid_producers_consumers array based on existing .yaml files
function populate_valid_producers_consumers() {
    for stage in "${!security_config_map[@]}"; do
        config_path="${security_config_map[$stage]}"
        if check_yaml_exists "$config_path"; then
            valid_producers_consumers+=("$stage")
        fi
    done
}

# Call the function to populate the valid_producers_consumers array
populate_valid_producers_consumers

# Displays the table formatting.
tableprint() {
    printf "\t\t "
    printf "~%.0s" {1..154}
    printf "\n"
}

# Describing the usage of the run.sh shell script.
usage() {
  printf "Usage: $0 [\033[1m-s|--stage\033[0m <stage>] [[\033[1m-t|--tfcommand\033[0m <command>] [\033[1m-h|--help\033[0m]\n"
  printf " \033[1m-h, --help\033[0m              Displays the detailed help.\n"
  printf " \033[1m-s, --stage\033[0m             STAGENAME to be executed (STAGENAME is case insensitive). e.g. '-s all'  \n\t Valid options are: \n"
  tableprint
  printf "\t\t |%-40s| %-110s|\n" "STAGENAME" "Description"
  tableprint
  for stage_name in $valid_stages; do
    value=$(get_value $stage_name "stage_wise_description_map")
    printf "\t\t |%-40s| %-110s|\n" "$stage_name"  "$value"
  done
  tableprint
  printf " \033[1m-t, --tfcommand\033[0m         TFCOMMAND to be executed (TFCOMMAND is case insensitive). e.g. '-t init' \n\t Valid options are: \n"
  tableprint
  printf "\t\t |%-40s| %-110s|\n" "TFCOMMAND" "Description"
  tableprint
  for tfcommand_value in $valid_tf_commands; do
    value=$(get_value $tfcommand_value "tfcommand_wise_description_map")
    printf "\t\t |%-40s| %-110s|\n" "$tfcommand_value"  "$value"
  done
  tableprint
}

# This function asks for a confirmation before a user provides a auto-approve functionality
confirm() {
    while true; do
        echo -e "${RED} [WARNING] : This action modifies existing resources on all stages without further confirmation. Proceed with caution..${NC}"
        read -p "Do you want to continue. Please answer y or n. $1 (y/n) " confirmation_input
        case $confirmation_input in
            [Yy]* ) break;; # If user confirms, exit the loop
            [Nn]* ) exit 1;; # If user declines, exit the script
            * ) echo "Please answer yes or no.";; # Handle invalid input
        esac
    done
}

# Handle arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s | --stage)
            stage="$2"
            if [[ ! " $valid_stages " =~ " $stage " ]]; then
                printf "${RED}Error: Invalid stage '$stage'. Valid options are: '${valid_stages// /\',\'}' ${NC}" >&2
                exit 1
            fi
            shift 2 ;;
        -t | --tfcommand)
            tfcommand="$2"
            if [[ ! " $valid_tf_commands " =~ " $tfcommand " ]]; then
                printf "${RED}Error: Invalid Terraform command '$tfcommand'. Valid options are: '${valid_tf_commands// /\',\'}' ${NC}" >&2
                exit 1
            fi
            shift 2 ;;
        -h | --help)
            usage
            exit 0 ;;
        *)
            echo "${RED}Invalid option: $1${NC}" >&2
            usage
            exit 1 ;;
    esac
done

# Shift to remove processed options from positional arguments
shift $((OPTIND-1))

# Error handling: Check if both flags are provided
if [ -z "$stage" ] || [ -z "$tfcommand" ]; then
  usage
  exit 1
fi

# Execute Terraform commands based on the stage and tfcommand
if [[ $stage == "all" ]]; then
  # Handles execution of all stages one by one when stage="all" is specified.
  # Create an array of stage paths in the correct sequential order ensuring the incremental order is maintained
  stage_path_array=()
  for stage_name in $valid_stages; do
    if [[ $stage_name != "all" ]]; then
      stage_path_value=$(get_value "$stage_name" "stage_path_map")
      stage_path_array+=("${stage_path_value}")
    fi
  done
  # Determine execution order based on tfcommand, reverse the order of execution if the -tf/--tfcommand contain destroy/deletion instructions
  if [[ $tfcommand == destroy || $tfcommand == destroy-auto-approve ]]; then
     reversed_array=()  # Initialize reversed_array
     for (( i=${#stage_path_array[@]}-1; i>=0; i-- )); do
        reversed_array+=("${stage_path_array[i]}")
    done
    stage_path_array=("${reversed_array[@]}")
  fi

  # Present a warning if a user uses auto-approve flag
  if [[ $tfcommand =~ "auto-approve" ]]; then
    confirm
  fi

  # Iterate over stages in the determined order
  for stage_path in "${stage_path_array[@]}"; do
      execute_terraform=true # Default value set to true.

      # Check if the current stage path is a security stage
      if [[ "$stage_path" == "03-security/"* ]]; then
          # Check if the stage_path exists in the security_config_map
          for security_stage_path in "${security_config_map[@]}"; do
              key="${security_stage_path%%=*}"
              if [[ "$key" == "$stage_path" ]]; then
                  config_path="${security_stage_path#*=}"
                  if ! check_yaml_exists "$config_path"; then
                      echo "${RED}Skipping $stage_path: No YAML files found.${NC}"
                      execute_terraform=false # Set to false if no config found.
                  fi
                  break
              fi
          done
      fi

      # Only execute Terraform commands if execute_terraform is true
      if [[ "$execute_terraform" == true ]]; then
         echo -e "Executing Terraform command(s) in ${GREEN}$stage_path${NC}..."
         tfvar_file_path=$(get_value "$stage_path" "stagewise_tfvar_path_map")
         echo "tfvars file path : ${tfvar_file_path}"
         (cd "$stage_path" &&
           case "$tfcommand" in
               init) terraform init -var-file="$tfvar_file_path" ;;
               apply) terraform apply -var-file="$tfvar_file_path" ;;
               apply-auto-approve) terraform apply --auto-approve -var-file="$tfvar_file_path" ;;
               destroy) terraform destroy -var-file="$tfvar_file_path" ;;
               destroy-auto-approve) terraform destroy -var-file="$tfvar_file_path" --auto-approve ;;
               init-apply) terraform init && terraform apply -var-file="$tfvar_file_path" ;;
               init-apply-auto-approve) terraform init && terraform apply -var-file="$tfvar_file_path" --auto-approve ;;
               *) echo "${RED}Error: Invalid tfcommand '$tfcommand'${NC}" >&2; exit 1 ;;
           esac)
      fi
  done
else
  # Otherwise, get the path for the specified stage. Logic for single stage execution
  stage_path=$(get_value "$stage" "stage_path_map")
  tfvar_file_path=$(get_value "$stage_path" "stagewise_tfvar_path_map")

  echo "tfvars file path : ${tfvar_file_path}"

  if [[ -z "$stage_path" ]]; then  # Check if a path was found
      echo "${RED}: Unexpected error finding path for stage '$stage'${NC}" >&2
      exit 1
  else
    echo "Executing Terraform command(s) in $stage_path..."
    (cd "$stage_path" &&
      case "$tfcommand" in
          init) terraform init -var-file="$tfvar_file_path";;
          apply) terraform apply -var-file="$tfvar_file_path";;
          apply-auto-approve) terraform apply -var-file=$tfvar_file_path --auto-approve ;;
          destroy) terraform destroy -var-file="$tfvar_file_path";;
          destroy-auto-approve) terraform destroy -var-file="$tfvar_file_path" --auto-approve;;
          init-apply) terraform init && terraform apply -var-file="$tfvar_file_path";;
          init-apply-auto-approve) terraform init && terraform apply -var-file=$tfvar_file_path --auto-approve ;;
          *) echo "${RED}Error: Invalid tfcommand '$tfcommand'${NC}" >&2; exit 1 ;;
      esac
    )
  fi
fi
