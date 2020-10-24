variable "subscription_id" {
    type = string
    default = "71b31109-7544-4940-9afd-3e97074f8941"
}

# variable "access_key" {
#     type = string
#     default = "SPBZvDNRYVm/sT3ODT5Zw2N/ql4VvjVFIvLAXH/g7yKYW3bqcgiwM4gmUd2s/CvNjTce9KvqBgbu8XdAXRTDFw=="
# }

variable "prefix" {
    type = string
    default = "demo"
}

variable "location" {
    type = string
    default = "westus"
}

variable "environment" {
    type = string
    default = "dev"
}

variable "functionapp" {
    type = string
    default = "$(Agent.BuildDirectory)/s/release/functionapp/src.zip"
}

resource "random_string" "storage_name" {
    length = 24
    upper = false
    lower = true
    number = true
    special = false
}

resource "random_string" "priv_storage_name" {
    length = 24
    upper = false
    lower = true
    number = true
    special = false
}

variable "department" {
  type    = string
  description = "A sample variable passed from the build pipeline and used to tag resources."
  default = "Engineering"
}

variable "sql2password" {
  type    = string
  description = "A password for SQL Server #2"
}