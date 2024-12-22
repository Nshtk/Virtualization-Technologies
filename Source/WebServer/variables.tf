variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "The default zone"
}
variable "cloud_id" {
  type        = string
  description = "The cloud ID"
}
variable "sa_name" {
  type        = string
  description = "Service account name"
}

variable "folder_id" {
  type        = string
  description = "The folder ID"
}
variable "bucket_name" {
  type        = string
  description = "The bucket name"
}

#variable "network_name" {
#  description = "The name of main network"
#  type        = string
#}