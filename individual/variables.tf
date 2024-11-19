variable "workload_protection_instance_crn" {
  type        = string
  description = "Namespace of the Security and Compliance Workload Protection agent."
  default     = "ibm-scc-wp"
}

variable "region" {
  type        = string
  description = "Region to deploy resources App Configuration in the Management account and Workload Protection in the 'wp_account'"
  default     = "eu-gb"
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group in which to provision resources to. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
  default     = "Default"
}

variable "prefix" {
  type        = string
  description = "Prefix to be used as name in all created resources: Workload Protection, Trusted Profiles and App Configuration instance."
  default     = "ibm-cloud-cspm"
}

variable "app_config_plan" {
  type        = string
  description = "App Configuration plan. No cost associated to configuration aggregation."
  default     = "basic"
}

variable "apikey" {
  type        = string
  description = "API Key to be onboarded and all resources will be created."
}
