// Package test contains integration tests for the root Terraform module.
//
// These tests use Terratest to deploy the module into a real Azure subscription,
// assert that key outputs and resource properties are correct, then tear down.
//
// Prerequisites:
//   - Go 1.21+
//   - Azure credentials available via ARM_* environment variables or a service principal
//   - Sufficient subscription quota for App Service P1v3, PostgreSQL Flexible Server, Key Vault
//
// Run:
//
//	cd test
//	go test -v -timeout 60m -run TestRootModule
package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestRootModule deploys the root module with minimal test variables, asserts
// that all required outputs are non-empty, and verifies key naming conventions.
func TestRootModule(t *testing.T) {
	t.Parallel()

	// Generate a short unique suffix so parallel runs don't collide on resource names.
	suffix := strings.ToLower(random.UniqueId()) // 6-char alphanumeric

	appName := fmt.Sprintf("ttest%s", suffix) // e.g. ttesta1b2c3
	environment := "dev"
	expectedNamePrefix := fmt.Sprintf("%s-%s", appName, environment)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../", // workspace root
		Vars: map[string]interface{}{
			"app_name":          appName,
			"environment":       environment,
			"location":          "eastus2",
			"db_admin_password": generateTestPassword(suffix),
			// Keep SKUs small/cheap for test runs
			"app_service_sku": "B1",
			"db_sku":          "Standard_B1ms",
			"db_storage_mb":   32768,
			"kv_sku":          "standard",
		},
		// Suppress verbose plan output in CI; set TF_LOG=DEBUG to re-enable.
		NoColor: true,
	})

	// Always destroy after the test — even on failure.
	defer terraform.Destroy(t, terraformOptions)

	// Deploy.
	terraform.InitAndApply(t, terraformOptions)

	// ----------------------------------------------------------------
	// Output assertions
	// ----------------------------------------------------------------

	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	require.NotEmpty(t, resourceGroupName, "resource_group_name output must not be empty")
	assert.Equal(
		t,
		fmt.Sprintf("%s-rg", expectedNamePrefix),
		resourceGroupName,
		"resource group name must follow <app>-<env>-rg convention",
	)

	appServiceURL := terraform.Output(t, terraformOptions, "app_service_url")
	require.NotEmpty(t, appServiceURL, "app_service_url output must not be empty")
	assert.Contains(
		t,
		appServiceURL,
		".azurewebsites.net",
		"app_service_url should be an azurewebsites.net hostname",
	)

	keyVaultURI := terraform.Output(t, terraformOptions, "key_vault_uri")
	require.NotEmpty(t, keyVaultURI, "key_vault_uri output must not be empty")
	assert.True(
		t,
		strings.HasPrefix(keyVaultURI, "https://"),
		"key_vault_uri must be an HTTPS URI",
	)
	assert.Contains(
		t,
		keyVaultURI,
		".vault.azure.net",
		"key_vault_uri should point to vault.azure.net",
	)

	dbHost := terraform.Output(t, terraformOptions, "db_host")
	require.NotEmpty(t, dbHost, "db_host output must not be empty")
	assert.Contains(
		t,
		dbHost,
		".postgres.database.azure.com",
		"db_host should be a postgres.database.azure.com FQDN",
	)

	vnetID := terraform.Output(t, terraformOptions, "vnet_id")
	require.NotEmpty(t, vnetID, "vnet_id output must not be empty")
	assert.Contains(
		t,
		strings.ToLower(vnetID),
		"/providers/microsoft.network/virtualnetworks/",
		"vnet_id should be an Azure VNet resource ID",
	)

	logAnalyticsID := terraform.Output(t, terraformOptions, "log_analytics_workspace_id")
	require.NotEmpty(t, logAnalyticsID, "log_analytics_workspace_id output must not be empty")
	assert.Contains(
		t,
		strings.ToLower(logAnalyticsID),
		"/providers/microsoft.operationalinsights/workspaces/",
		"log_analytics_workspace_id should be a Log Analytics resource ID",
	)

	// ----------------------------------------------------------------
	// Naming convention assertions
	// ----------------------------------------------------------------

	assert.Contains(
		t,
		strings.ToLower(vnetID),
		fmt.Sprintf("%s-vnet", expectedNamePrefix),
		"VNet resource ID must contain the expected name prefix",
	)

	assert.Contains(
		t,
		strings.ToLower(logAnalyticsID),
		fmt.Sprintf("%s-law", expectedNamePrefix),
		"Log Analytics workspace resource ID must contain the expected name prefix",
	)
}

// TestVariableValidation confirms that invalid variable values are rejected
// before any resources are created (plan-time validation).
func TestVariableValidation(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name    string
		varName string
		value   interface{}
	}{
		{
			name:    "invalid environment",
			varName: "environment",
			value:   "production", // only dev/staging/prod are allowed
		},
		{
			name:    "invalid kv_sku",
			varName: "kv_sku",
			value:   "basic", // only standard/premium are allowed
		},
	}

	for _, tc := range cases {
		tc := tc // capture range var
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			opts := &terraform.Options{
				TerraformDir: "../",
				Vars: map[string]interface{}{
					"app_name":          "validtest",
					"environment":       "dev",
					"db_admin_password": "Placeholder1!",
					tc.varName:          tc.value,
				},
				NoColor: true,
			}

			// InitAndPlan should exit non-zero due to validation failure.
			_, err := terraform.InitAndPlanE(t, opts)
			assert.Error(t, err, "expected terraform plan to fail for invalid %s=%v", tc.varName, tc.value)
		})
	}
}

// generateTestPassword creates a deterministic but sufficiently complex
// password for CI use. NOT for production — never reuse this pattern.
func generateTestPassword(suffix string) string {
	return fmt.Sprintf("Ttest-%s-P4ss!", suffix)
}
