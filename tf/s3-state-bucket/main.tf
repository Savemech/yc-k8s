resource "random_id" "getrandom" {
  byte_length = 4
}
resource "yandex_iam_service_account" "bucket-tf-states-sa" {
  name        = "tf-status-bucket-sa-${lower(random_id.getrandom.hex)}"
  description = "managing states for bucket on tf-status-bucket-${lower(random_id.getrandom.hex)}"
}
resource "yandex_resourcemanager_folder_iam_member" "bucket-tf-states-sa-member" {
  folder_id  = var.folder_id
  role       = "editor"
  member     = "serviceAccount:${yandex_iam_service_account.bucket-tf-states-sa.id}"
  depends_on = [yandex_iam_service_account.bucket-tf-states-sa]
}
resource "yandex_storage_bucket" "tf-status-bucket" {
  bucket     = "tf-status-bucket-${lower(random_id.getrandom.hex)}"
  acl        = "private"
  depends_on = [yandex_iam_service_account.bucket-tf-states-sa, yandex_resourcemanager_folder_iam_member.bucket-tf-states-sa-member, random_id.getrandom]
}
