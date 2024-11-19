# Enterprise onboarding for IBM Cloud CSPM
This Terraform example creates all prerequirements to onboard an IBM Cloud Enterprise into SCC Workload Protection.

The following resources need to be created in the management account:
- Trusted Profile Templates and Policies for configuration aggregation
- Trusted Profile for SCC-WP and App Configuration
- App Configuration with Config Aggregator enabled

You can control where SCC Workload Protection instance is created:
- **With `management_account_apikey` you introduce the API Key for the Management account.**
- **With `wp_account_apikey` you introduce the API Key for the account where you want to create SCC Workload Protection.**

Note: If you introduce the same API Key for both, SCC Workload Protection will be created in the Management account.

# Manual step for onboarding
Once you have run this Terraform, you need to perform a final step with the CLI due to existing dependencies between SCC Workload Protection instance and the Trusted Profile.

As part of the Output, you will see the exact command to onboard your enterprise that will be something like:
```
ibmcloud resource service-instance-update <workload protection instance name> -p '{"enable_cspm": true, "target_accounts": [{"config_crn": "<app config CRN>", "account_id": "<enterprise ID>", "trusted_profile_id": "<Trusted Profile ID>", "account_type": "ENTERPRISE"}]}' -g <resource group>"
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.70.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ibm.management"></a> [ibm.management](#provider\_ibm.management) | 1.71.2 |
| <a name="provider_ibm.wp_account"></a> [ibm.wp\_account](#provider\_ibm.wp\_account) | 1.71.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_config_aggregator_settings.config_aggregator_settings_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/config_aggregator_settings) | resource |
| [ibm_iam_policy_template.profile_template_policy_all_identity](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_policy_template) | resource |
| [ibm_iam_policy_template.profile_template_policy_all_management](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_policy_template) | resource |
| [ibm_iam_trusted_profile.config_service_profile](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile) | resource |
| [ibm_iam_trusted_profile.config_service_profile_enterprise](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile) | resource |
| [ibm_iam_trusted_profile.workload_protection_profile](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile) | resource |
| [ibm_iam_trusted_profile_identity.trust_relationship_config_service](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_identity) | resource |
| [ibm_iam_trusted_profile_identity.trust_relationship_enterprise_config_service](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_identity) | resource |
| [ibm_iam_trusted_profile_identity.trust_relationship_workload_protection](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_identity) | resource |
| [ibm_iam_trusted_profile_policy.policy_config_service_all_account](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_policy) | resource |
| [ibm_iam_trusted_profile_policy.policy_config_service_all_identity](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_policy) | resource |
| [ibm_iam_trusted_profile_policy.policy_config_service_enterprise](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_policy) | resource |
| [ibm_iam_trusted_profile_policy.policy_config_service_enterprise_all_iam](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_policy) | resource |
| [ibm_iam_trusted_profile_policy.policy_workload_protection_apprapp](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_policy) | resource |
| [ibm_iam_trusted_profile_policy.policy_workload_protection_enterprise](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_policy) | resource |
| [ibm_iam_trusted_profile_template.trusted_profile_template_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_template) | resource |
| [ibm_iam_trusted_profile_template_assignment.account_settings_template_assignment_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_template_assignment) | resource |
| [ibm_resource_instance.app_configuration_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.workload_protection_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_enterprise_accounts.all_accounts](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/enterprise_accounts) | data source |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |
| [ibm_resource_group.group](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |
| [ibm_resource_group.wp_account_group](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enterprise_id"></a> [enterprise\_id](#input\_enterprise\_id) | Enterprise ID to be used for App Configuration aggregator | `string` | n/a | yes |
| <a name="input_management_account_apikey"></a> [management\_account\_apikey](#input\_management\_account\_apikey) | Management Account API Key to create Trusted Profile and the App Configuration instance. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be used as name in all created resources: Workload Protection, Trusted Profiles and App Configuration instance | `string` | `"ibm-cloud-cspm"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy resources App Configuration in the Management account and Workload Protection in the 'wp\_account' | `string` | `"eu-gb"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of a new or an existing resource group in which to provision resources to. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"Default"` | no |
| <a name="input_wp_account_apikey"></a> [wp\_account\_apikey](#input\_wp\_account\_apikey) | API Key for the Account where Workload Protection will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_command_to_onboard"></a> [command\_to\_onboard](#output\_command\_to\_onboard) | n/a |
<!-- END_TF_DOCS -->