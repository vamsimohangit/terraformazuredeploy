# Azure Subscription Id
variable "azure-subscription-id" {
  type        = string
  description = "Azure Subscription Id"
}
# Azure Client Id/appId
variable "azure-client-id" {
  type        = string
  description = "Azure Client Id/appId"
}
# Azure Client Id/appId
variable "azure-client-secret" {
  type        = string
  description = "Azure Client Id/appId"
}
# Azure Tenant Id
variable "azure-tenant-id" {
  type        = string
  description = "Azure Tenant Id"
}
##################################################################################

variable "vm_username" {
  type  = string
}

variable "vm_password" {
  type  = string
}

variable "vm_image" {
  type  = string
}

variable "vm_instancesize" {
  type  = string
}
##################################################################
variable "node_location" {
type = string
}
variable "resource_prefix" {
type = string
}
variable "node_address_space" {
default = ["1.0.0.0/16"]
}
#variable for network range
variable "node_address_prefix" {
default = "1.0.1.0/24"
}
#variable for Environment
variable "Environment" {
type = string
}
variable "node_count" {
type = number
}
variable "instance_name" {
type = string
}
variable "dns_name" {
type = string
}

variable "sqlservername" {
type = string
}
variable "sqladmin" {
type = string
}

variable "sqlpassword" {
type = string
}