variable "vm_server_rg" {
  type = string
  default = "my-test-candidate"

}
variable "vm_server_location" {
  type    = list(string)
  default = {
    ["westus", "eastus"]
  }
}

variable "resource_prefix" {
  type = string
}

variable "vm_server_address_space" {
  type = string
}

variable "vm_server_address_prefix" {
  type = string
}

variable "vm_server_name" {
  type = string
  default = "my-test-candidate"
}

variable "environment" {
  type = string
}
variable "location" {
  type = string
  default = "eastus"
}
