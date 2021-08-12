package tests

import (
	"testing"

	"fmt"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformAwsHelloWorldExample(t *testing.T) {
	t.Parallel()

	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../modules/ec2",
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the IP of the instance
	publicIp := terraform.Output(t, terraformOptions, "public_ip")

	// Make sure the instance is in running state
	output := terraform.OutputAll(t, terraformOptions)
	assert.Equal(t, output["instance_state"], "running")

	// Make an HTTP request to the instance and make sure we get back a 200 OK with the body "Hello, World!" 
	// Loop of 60 runs with wait for 10 seconds before the next retry
	url := fmt.Sprintf("http://%s:8080", publicIp)
	http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 60, 10*time.Second)
}
