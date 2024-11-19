data "ibm_resource_group" "group" {
  provider = ibm.management
  name     = var.resource_group_name
}

data "ibm_resource_group" "wp_account_group" {
  provider = ibm.wp_account
  name     = var.resource_group_name
}

data "ibm_iam_account_settings" "iam_account_settings" {
  provider = ibm.management
}

## Workload Protection ###
resource "ibm_resource_instance" "workload_protection_instance" {
  provider          = ibm.wp_account
  plan              = "graduated-tier"
  name              = "${var.prefix}-workload-protection"
  location          = var.region
  resource_group_id = data.ibm_resource_group.wp_account_group.id
  service           = "sysdig-secure"
}

# Trusted Profile for Workload Protection created in the Management account
resource "ibm_iam_trusted_profile" "workload_protection_profile" {
  provider = ibm.management
  name     = "${var.prefix}-workload-protection-trusted-profile"
}

# Trusted Profile Policy for All Account Management services for WP created in the Management account
resource "ibm_iam_trusted_profile_policy" "policy_workload_protection_enterprise" {
  provider    = ibm.management
  profile_id  = ibm_iam_trusted_profile.workload_protection_profile.id
  roles       = ["Viewer", "Usage Report Viewer"]
  description = "Enterprise"
  resources {
    service = "enterprise"
  }
}

# Trusted Profile Policiy for All Identify and Access enabled services for WP created in the Management account
resource "ibm_iam_trusted_profile_policy" "policy_workload_protection_apprapp" {
  provider    = ibm.management
  profile_id  = ibm_iam_trusted_profile.workload_protection_profile.id
  roles       = ["Manager", "Configuration Aggregator Reader"]
  description = "apprapp"
  resources {
    service = "apprapp"
  }
}

# Trusted Profile Trust Relationship for Config Service created in the Management account
resource "ibm_iam_trusted_profile_identity" "trust_relationship_workload_protection" {
  provider      = ibm.management
  identifier    = ibm_resource_instance.workload_protection_instance.crn
  identity_type = "crn"
  profile_id    = ibm_iam_trusted_profile.workload_protection_profile.id
  type          = "crn"
}

# ######################
# ### Config Service ###
# ######################

resource "ibm_resource_instance" "app_configuration_instance" {
  provider          = ibm.management
  plan              = "basic"
  name              = "${var.prefix}-config-aggregator"
  location          = var.region
  resource_group_id = data.ibm_resource_group.group.id
  service           = "apprapp"
}

# Config Service Aggregator
resource "ibm_config_aggregator_settings" "config_aggregator_settings_instance" {
  provider    = ibm.management
  instance_id = ibm_resource_instance.app_configuration_instance.guid
  region      = var.region

  resource_collection_regions = ["all"]
  resource_collection_enabled = true
  trusted_profile_id          = ibm_iam_trusted_profile.config_service_profile.id

  additional_scope {
    type          = "Enterprise"
    enterprise_id = var.enterprise_id
    profile_template {
      id                 = split("/", ibm_iam_trusted_profile_template.trusted_profile_template_instance.id)[0]
      trusted_profile_id = ibm_iam_trusted_profile.config_service_profile_enterprise.id
    }
  }
}

### Trusted Profile configuration for general usage ###
#######################################################

# Trusted Profile for Config Service
resource "ibm_iam_trusted_profile" "config_service_profile" {
  provider = ibm.management
  name     = "${var.prefix}-config-service-trusted-profile"
}

# Trusted Profile Policy for All Account Management services for Config Service
resource "ibm_iam_trusted_profile_policy" "policy_config_service_all_account" {
  provider           = ibm.management
  profile_id         = ibm_iam_trusted_profile.config_service_profile.id
  roles              = ["Viewer", "Service Configuration Reader"]
  description        = "All Account Management services"
  account_management = true
  # resources {
  #   service = "All Account Management services"
  # }
}

# Trusted Profile Policiy for All Identify and Access enabled services for Config Service
resource "ibm_iam_trusted_profile_policy" "policy_config_service_all_identity" {
  provider    = ibm.management
  profile_id  = ibm_iam_trusted_profile.config_service_profile.id
  roles       = ["Reader", "Viewer", "Service Configuration Reader"]
  description = "All Identity and Access enabled services"
  resource_attributes {
    name  = "serviceType"
    value = "service"
  }
}

# Trusted Profile Trust Relationship for Config Service
resource "ibm_iam_trusted_profile_identity" "trust_relationship_config_service" {
  provider      = ibm.management
  identifier    = ibm_resource_instance.app_configuration_instance.crn
  identity_type = "crn"
  profile_id    = ibm_iam_trusted_profile.config_service_profile.id
  type          = "crn"
}

### Trusted Profile configuration to read Templates and Enterprise ###
######################################################################

# Trusted Profile for Config Service
resource "ibm_iam_trusted_profile" "config_service_profile_enterprise" {
  provider = ibm.management
  name     = "${var.prefix}-config-service-enterprise"
}

# Trusted Profile Policy for All IAM Account Management services for Config Service
resource "ibm_iam_trusted_profile_policy" "policy_config_service_enterprise_all_iam" {
  provider    = ibm.management
  profile_id  = ibm_iam_trusted_profile.config_service_profile_enterprise.id
  roles       = ["Viewer", "Template Administrator", "Assignment Administrator"]
  description = "All IAM Account Management services"
  resource_attributes {
    name  = "service_group_id"
    value = "IAM"
  }
}

# Trusted Profile Policiy for All Identify and Access enabled services for Config Service
resource "ibm_iam_trusted_profile_policy" "policy_config_service_enterprise" {
  provider    = ibm.management
  profile_id  = ibm_iam_trusted_profile.config_service_profile_enterprise.id
  roles       = ["Viewer"]
  description = "Enterprise"
  resources {
    service = "enterprise"
  }
}

# Trusted Profile Trust Relationship for Config Service
resource "ibm_iam_trusted_profile_identity" "trust_relationship_enterprise_config_service" {
  provider      = ibm.management
  identifier    = ibm_resource_instance.app_configuration_instance.crn
  identity_type = "crn"
  profile_id    = ibm_iam_trusted_profile.config_service_profile_enterprise.id
  type          = "crn"
}


### Trusted Profile template for Enterprise ###

# Trusted Policy Template Policy -- All Identity and Access enabled service
resource "ibm_iam_policy_template" "profile_template_policy_all_identity" {
  provider = ibm.management
  name     = "${var.prefix}-all-identity-policy-template"
  policy {
    type        = "access"
    description = "Reader access for All Identity and Access enabled services"
    resource {
      attributes {
        key      = "serviceType"
        operator = "stringEquals"
        value    = "service"
      }

    }
    roles = ["Viewer", "Service Configuration Reader", "Reader", "Manager"] # Manager just to avoid conflict
  }
  committed = "true"
}

# Trusted Policy Template Policy -- All Account Management Services
resource "ibm_iam_policy_template" "profile_template_policy_all_management" {
  provider = ibm.management
  name     = "${var.prefix}-all-management-policy-template"
  policy {
    type        = "access"
    description = "Reader access for All Account Management Services"
    resource {
      attributes {
        key      = "serviceType"
        operator = "stringEquals"
        value    = "platform_service"
      }

    }
    roles = ["Viewer", "Service Configuration Reader", "Administrator"] # Administrator just to avoid conflict
  }
  committed = "true"
}

# Trusted Profile Template 
resource "ibm_iam_trusted_profile_template" "trusted_profile_template_instance" {
  provider    = ibm.management
  name        = "${var.prefix}-trusted-profile-template"
  description = "${var.prefix}-trusted-profile-template"
  profile {
    name        = "Trusted Profile for IBM Cloud CSPM in SCC-WP"
    description = "description of Trusted Profile for IBM Cloud CSPM in SCC-WP"
  }

  policy_template_references {
    id      = ibm_iam_policy_template.profile_template_policy_all_identity.template_id
    version = ibm_iam_policy_template.profile_template_policy_all_identity.version
  }

  policy_template_references {
    id      = ibm_iam_policy_template.profile_template_policy_all_management.template_id
    version = ibm_iam_policy_template.profile_template_policy_all_management.version
  }

  committed = true
}

### Assignment to all accounts ###
##################################

data "ibm_enterprise_accounts" "all_accounts" {
  provider = ibm.management
}

# Trusted Profile assignemnt to all accounts
# We need to filer out the management account
resource "ibm_iam_trusted_profile_template_assignment" "account_settings_template_assignment_instance" {
  provider         = ibm.management
  for_each         = { for account in data.ibm_enterprise_accounts.all_accounts.accounts : account.id => account if account.id != data.ibm_iam_account_settings.iam_account_settings.account_id }
  template_id      = split("/", ibm_iam_trusted_profile_template.trusted_profile_template_instance.id)[0]
  template_version = ibm_iam_trusted_profile_template.trusted_profile_template_instance.version
  target           = each.value.id
  target_type      = "Account"
}

### OUTPUT ###

output "command_to_onboard" {
  value = <<PARAMETERS_JSON
    ibmcloud resource service-instance-update ${ibm_resource_instance.workload_protection_instance.name} -p '{"enable_cspm": true, "target_accounts": [{"config_crn": "${ibm_resource_instance.app_configuration_instance.id}", "account_id": "${var.enterprise_id}", "trusted_profile_id": "${ibm_iam_trusted_profile.workload_protection_profile.id}", "account_type": "ENTERPRISE"}]}' -g ${var.resource_group_name}"
  PARAMETERS_JSON
}
