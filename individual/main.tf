data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

data "ibm_iam_account_settings" "iam_account_settings" {
}

## Workload Protection ###
resource "ibm_resource_instance" "workload_protection_instance" {
  plan              = "graduated-tier"
  name              = "${var.prefix}-workload-protection"
  location          = var.region
  resource_group_id = data.ibm_resource_group.group.id
  service           = "sysdig-secure"
  parameters_json   = <<PARAMETERS_JSON
    {
      "enable_cspm" : true,
      "target_accounts" : [{
        "account_id" : "${data.ibm_iam_account_settings.iam_account_settings.account_id}",
        "config_crn" : "${ibm_resource_instance.app_configuration_instance.id}",
        "trusted_profile_id" : "${ibm_iam_trusted_profile.workload_protection_profile.id}"
      }]
    }
  PARAMETERS_JSON
}

# Trusted Profile for Workload Protection
resource "ibm_iam_trusted_profile" "workload_protection_profile" {
  name = "${var.prefix}-workload-protection-trusted-profile"
}

# Trusted Profile Policy for All Account Management services for WP
resource "ibm_iam_trusted_profile_policy" "policy_workload_protection_enterprise" {
  profile_id  = ibm_iam_trusted_profile.workload_protection_profile.id
  roles       = ["Viewer", "Usage Report Viewer"]
  description = "Enterprise"
  resources {
    service = "enterprise"
  }
}

# Trusted Profile Policiy for All Identify and Access enabled services for WP
resource "ibm_iam_trusted_profile_policy" "policy_workload_protection_apprapp" {
  profile_id  = ibm_iam_trusted_profile.workload_protection_profile.id
  roles       = ["Manager", "Configuration Aggregator Reader"]
  description = "apprapp"
  resources {
    service = "apprapp"
  }
}

# Trusted Profile Trust Relationship for Config Service
resource "ibm_iam_trusted_profile_identity" "trust_relationship_workload_protection" {
  identifier    = ibm_resource_instance.app_configuration_instance.crn
  identity_type = "crn"
  profile_id    = ibm_iam_trusted_profile.workload_protection_profile.id
  type          = "crn"
}

######################
### Config Service ###
######################

resource "ibm_resource_instance" "app_configuration_instance" {
  plan              = var.app_config_plan
  name              = "${var.prefix}-config-aggregator"
  location          = var.region
  resource_group_id = data.ibm_resource_group.group.id
  service           = "apprapp"
}

# Config Service Aggregator
resource "ibm_config_aggregator_settings" "config_aggregator_settings_instance" {
  instance_id = ibm_resource_instance.app_configuration_instance.guid
  region      = var.region

  resource_collection_regions = ["all"]
  resource_collection_enabled = true
  trusted_profile_id          = ibm_iam_trusted_profile.config_service_profile.id
}

# Trusted Profile for Config Service
resource "ibm_iam_trusted_profile" "config_service_profile" {
  name = "${var.prefix}-config-service-trusted-profile"
}

# Trusted Profile Policy for All Account Management services for Config Service
resource "ibm_iam_trusted_profile_policy" "policy_config_service_all_account" {
  profile_id  = ibm_iam_trusted_profile.config_service_profile.id
  roles       = ["Viewer", "Service Configuration Reader"]
  description = "All Account Management services"
  resources {
    service = "All Account Management services"
  }
}

# Trusted Profile Policiy for All Identify and Access enabled services for Config Service
resource "ibm_iam_trusted_profile_policy" "policy_config_service_all_identity" {
  profile_id  = ibm_iam_trusted_profile.config_service_profile.id
  roles       = ["Viewer", "Service Configuration Reader"]
  description = "All Identity and Access enabled services"
  resources {
    service = "All Identity and Access enabled services"
  }
}

# Trusted Profile Trust Relationship for Config Service
resource "ibm_iam_trusted_profile_identity" "trust_relationship_config_service" {
  identifier    = ibm_resource_instance.app_configuration_instance.crn
  identity_type = "crn"
  profile_id    = ibm_iam_trusted_profile.config_service_profile.id
  type          = "crn"
}

### OUTPUT ###

output "command_to_onboard" {
  value = <<PARAMETERS_JSON
    ibmcloud resource service-instance-update ${ibm_resource_instance.workload_protection_instance.name} -p '{"enable_cspm": true, "target_accounts": [{"config_crn": "${ibm_resource_instance.app_configuration_instance.id}", "account_id": "${data.ibm_iam_account_settings.iam_account_settings.account_id}", "trusted_profile_id": "${ibm_iam_trusted_profile.workload_protection_profile.id}"}]}' -g ${var.resource_group_name}"
  PARAMETERS_JSON
}
