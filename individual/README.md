# Individual onboarding for IBM Cloud CSPM
This Terraform example creates all prerequirements to onboard an IBM Cloud individual into SCC Workload Protection.

The following resources need to be created in the management account:
- Trusted Profile for SCC-WP and App Configuration
- App Configuration with Config Aggregator enabled

You can control where SCC Workload Protection instance is created:
- **With `apikey` you introduce the API Key for the Management account.**

# Manual step for onboarding
Once you have run this Terraform, you need to perform a final step with the CLI due to existing dependencies between SCC Workload Protection instance and the Trusted Profile.

As part of the Output, you will see the exact command to onboard your individual that will be something like:
```
ibmcloud resource service-instance-update <workload protection instance name> -p '{"enable_cspm": true, "target_accounts": [{"config_crn": "<app config CRN>", "account_id": "<account ID>", "trusted_profile_id": "<Trusted Profile ID>"}]}' -g <resource group>"
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.12.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ibm"></a> [ibm](#provider\_ibm) | 1.71.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_config_aggregator_settings.config_aggregator_settings_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/config_aggregator_settings) | resource |
| [ibm_iam_trusted_profile.config_service_profile](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile) | resource |
| [ibm_iam_trusted_profile.workload_protection_profile](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile) | resource |
| [ibm_iam_trusted_profile_identity.trust_relationship_config_service](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_identity) | resource |
| [ibm_iam_trusted_profile_identity.trust_relationship_workload_protection](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_identity) | resource |
| [ibm_iam_trusted_profile_policy.policy_config_service_all_account](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_policy) | resource |
| [ibm_iam_trusted_profile_policy.policy_config_service_all_identity](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_policy) | resource |
| [ibm_iam_trusted_profile_policy.policy_workload_protection_apprapp](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_policy) | resource |
| [ibm_iam_trusted_profile_policy.policy_workload_protection_enterprise](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_policy) | resource |
| [ibm_resource_instance.app_configuration_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.workload_protection_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |
| [ibm_resource_group.group](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apikey"></a> [apikey](#input\_apikey) | API Key to be onboarded and all resources will be created. | `string` | n/a | yes |
| <a name="input_app_config_plan"></a> [app\_config\_plan](#input\_app\_config\_plan) | App Configuration plan. No cost associated to configuration aggregation. | `string` | `"basic"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be used as name in all created resources: Workload Protection, Trusted Profiles and App Configuration instance. | `string` | `"ibm-cloud-cspm"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy resources App Configuration in the Management account and Workload Protection in the 'wp\_account' | `string` | `"eu-gb"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of a new or an existing resource group in which to provision resources to. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"Default"` | no |
| <a name="input_workload_protection_instance_crn"></a> [workload\_protection\_instance\_crn](#input\_workload\_protection\_instance\_crn) | Namespace of the Security and Compliance Workload Protection agent. | `string` | `"ibm-scc-wp"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_command_to_onboard"></a> [command\_to\_onboard](#output\_command\_to\_onboard) | n/a |
<!-- END_TF_DOCS -->