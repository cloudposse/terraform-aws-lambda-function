package test

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/lambda"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
		// We always include a random attribute so that parallel tests
		// and AWS resources do not interfere with each other
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	arn := terraform.Output(t, terraformOptions, "arn")
	invokeARN := terraform.Output(t, terraformOptions, "invoke_arn")
	qualifiedARN := terraform.Output(t, terraformOptions, "qualified_arn")
	functionName := terraform.Output(t, terraformOptions, "function_name")
	roleName := terraform.Output(t, terraformOptions, "role_name")
	roleARN := terraform.Output(t, terraformOptions, "role_arn")
	cloudwatchLogGroupARN := terraform.Output(t, terraformOptions, "cloudwatch_log_group_arn")
	cloudwatchLogGroupName := terraform.Output(t, terraformOptions, "cloudwatch_log_group_name")
	cloudwatchEventRuleIDs := terraform.OutputList(t, terraformOptions, "cloudwatch_event_rule_ids")
	cloudwatchEventRuleARNs := terraform.OutputList(t, terraformOptions, "cloudwatch_event_rule_arns")

	assert.Contains(t, arn, "arn:aws:lambda:")
	assert.Contains(t, invokeARN, "arn:aws:apigateway:")
	assert.Contains(t, qualifiedARN, "arn:aws:lambda:")
	assert.NotEmpty(t, functionName)
	assert.NotEmpty(t, roleName)
	assert.Contains(t, roleARN, "arn:aws:iam:")
	assert.Contains(t, cloudwatchLogGroupARN, "arn:aws:logs:")
	assert.NotEmpty(t, cloudwatchLogGroupName)
	assert.NotEmpty(t, cloudwatchEventRuleIDs)
	assert.NotEmpty(t, cloudwatchEventRuleARNs)

	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	client := lambda.New(sess, &aws.Config{Region: aws.String("us-east-2")})

	result, err := client.Invoke(&lambda.InvokeInput{FunctionName: aws.String(arn)})
	assert.Nil(t, err)

	var output map[string]interface{}
	err = json.Unmarshal([]byte(result.Payload), &output)
	assert.Nil(t, err)

	assert.Equal(t, "Hello World", output["data"])
}

// Test the Terraform module in examples/complete doesn't attempt to create resources with enabled=false.
func TestExamplesCompleteDisabled(t *testing.T) {
	testNoChanges(t, "../../examples/complete")
}
