provider "yandex" {
  token              = var.token
  cloud_id           = var.cloud_id
  folder_id          = var.folder_id
  zone               = var.zone
  storage_access_key = var.storage_access_key
  storage_secret_key = var.storage_secret_key
}

#data "terraform_remote_state" "tf-state-bucket" {
#  backend = "s3"                 
#  config = {            
#    bucket = "tf-status-bucket"
#    key    = "regular-kube-${lower(random_id.getrandom.hex)}.tfstate"
#        region                      = "us-east-1"
##    region                      = "ru-central1"              
#    endpoint                    = "storage.yandexcloud.net"
#    skip_region_validation      = "true"                         
#    skip_credentials_validation = "true"
#  }
#}

