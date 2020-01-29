variable "resource_prefix" {
  type = string
  description = "Enter a prefix that uniquely identifies your resources. e.g. username"
}

variable "gcp_project_id" {
  type = string
  description = "Enter the Google Cloud Project IP"
}
variable "gcp_region" {
  type    = string
  description = "Enter the Google Cloud Region (https://cloud.google.com/compute/docs/regions-zones#locations)"
  default = "asia-southeast1"
}

variable "gcp_zone" {
  type    = string
  description = "Enter the Google Cloud Zone (https://cloud.google.com/compute/docs/regions-zones#locations)"
  default = "asia-southeast1-b"
}

variable "machine_type" {
  type        = string
  default     = "g1-small"
  description = "Enter the Machine Type for your node pool (https://cloud.google.com/compute/docs/machine-types)"

}

variable "max_node_count" {
  type        = number
  default     = 3
  description = "Max number of nodes that your node pool can scale up to"
}

variable "initial_node_count" {
  type        = number
  default     = 1
  description = "The initial number of nodes for your node pool to start with"
}