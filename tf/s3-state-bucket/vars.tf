variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = ""
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = ""
}

variable "zone" {
  description = "Yandex Cloud default Zone for provisoned resources"
  default     = "ru-central1-c"
}

variable "zones" {
  description = "Yandex Cloud default Zone for provisoned resources"
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]
}

variable "zone_a_subnet_id" {
  description = "Yandex Cloud default Zone id for provisoned resources"
  default     = ""
}
variable "zone_b_subnet_id" {
  description = "Yandex Cloud default Zone id for provisoned resources"
  default     = ""
}
variable "zone_c_subnet_id" {
  description = "Yandex Cloud default Zone id for provisoned resources"
  default     = ""
}
