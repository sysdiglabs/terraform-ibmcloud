terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.70.0"
    }
  }
}

# Management account provider
provider "ibm" {
  alias            = "management"
  region           = var.region
  ibmcloud_api_key = var.management_account_apikey
}

provider "ibm" {
  alias            = "wp_account"
  region           = var.region
  ibmcloud_api_key = var.wp_account_apikey
}
