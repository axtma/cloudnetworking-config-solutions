// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package unittest

import (
	"testing"

	"github.com/google/go-cmp/cmp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"golang.org/x/exp/slices"
)

const (
	terraformDirectoryPath = "../../../../03-security/MIG"
	network                = "dummy-vpc-network01"
)

var (
	projectID = "dummy-project-id"
	tfVars    = map[string]any{
		"project_id": projectID,
		"network":    network,
		"ingress_rules": map[string]any{
			"fw-allow-health-check": map[string]any{
				"deny":               false,
				"description":        "Allow health checks",
				"destination_ranges": []any{},
				"disabled":           false,
				"enable_logging": map[string]any{
					"include_metadata": true,
				},
				"priority": 1000,
				"source_ranges": []string{
					"130.211.0.0/22",
					"35.191.0.0/16",
				},
				"targets": []string{"allow-health-checks"},
				"rules": []any{
					map[string]any{
						"protocol": "tcp",
						"ports":    []string{"80"},
					},
				},
			},
		},
	}
)

func TestInitAndPlanRunWithTfVars(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDirectoryPath,
		Vars:         tfVars,
		Reconfigure:  true,
		Lock:         true,
		PlanFilePath: "./plan",
		NoColor:      true,
	})
	planExitCode := terraform.InitAndPlanWithExitCode(t, terraformOptions)
	want := 2 // Expecting a specific exit code based on your logic
	got := planExitCode
	if got != want {
		t.Errorf("Test Plan Exit Code = %v, want = %v", got, want)
	}
}

func TestInitAndPlanRunWithoutTfVarsExpectFailureScenario(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDirectoryPath,
		Reconfigure:  true,
		Lock:         true,
		PlanFilePath: "./plan",
		NoColor:      true,
	})
	planExitCode := terraform.InitAndPlanWithExitCode(t, terraformOptions)
	want := 1 // Expecting failure when no tfvars are provided
	got := planExitCode
	if !cmp.Equal(got, want) {
		t.Errorf("Test Plan Exit Code = %v, want = %v", got, want)
	}
}

func TestResourcesCount(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDirectoryPath,
		Vars:         tfVars,
		Reconfigure:  true,
		Lock:         true,
		PlanFilePath: "./plan",
		NoColor:      true,
	})
	planStruct := terraform.InitAndPlan(t, terraformOptions)
	resourceCount := terraform.GetResourceCount(t, planStruct)
	if got, want := resourceCount.Add, 1; got != want {
		t.Errorf("Test Resource Count Add = %v, want = %v", got, want)
	}
	if got, want := resourceCount.Change, 0; got != want {
		t.Errorf("Test Resource Count Change = %v, want = %v", got, want)
	}
	if got, want := resourceCount.Destroy, 0; got != want {
		t.Errorf("Test Resource Count Destroy = %v, want = %v", got, want)
	}
}

func TestTerraformModuleResourceAddressListMatch(t *testing.T) {
	expectedModulesAddress := []string{"module.ssh_firewall"}
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDirectoryPath,
		Vars:         tfVars,
		Reconfigure:  true,
		Lock:         true,
		PlanFilePath: "./plan",
		NoColor:      true,
	})
	planStruct := terraform.InitAndPlanAndShow(t, terraformOptions)
	content, err := terraform.ParsePlanJSON(planStruct)
	if err != nil {
		t.Fatal(err.Error())
	}
	actualModuleAddresses := make([]string, 0)
	for _, element := range content.ResourceChangesMap {
		if element.ModuleAddress != "" && !slices.Contains(actualModuleAddresses, element.ModuleAddress) {
			actualModuleAddresses = append(actualModuleAddresses, element.ModuleAddress)
		}
	}
	want := expectedModulesAddress
	got := actualModuleAddresses
	if !cmp.Equal(got, want) {
		t.Errorf("Test Element Mismatch = %v, want = %v", got, want)
	}
}
