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
  description = "Prefix to be used as name in all created resources: Workload Protection, Trusted Profiles and App Configuration instance"
  default     = "ibm-cloud-cspm"
}

variable "enterprise_id" {
  type        = string
  description = "Enterprise ID to be used for App Configuration aggregator"
}

###############################
# API Keys for the 2 accounts #
###############################
variable "management_account_apikey" {
  type        = string
  description = "Management Account API Key to create Trusted Profile and the App Configuration instance."
}

variable "wp_account_apikey" {
  type        = string
  description = "API Key for the Account where Workload Protection will be created."
}
