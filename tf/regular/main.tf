resource "random_id" "getrandom" {
  byte_length = 4
}

resource "yandex_iam_service_account" "k8s_sa" {
  folder_id   = var.folder_id
  name        = "k8s-sa-${lower(random_id.getrandom.hex)}"
  description = "service account for cluster"
}

resource "yandex_iam_service_account" "k8s_node_sa" {
  folder_id   = var.folder_id
  name        = "k8s-node-sa-${lower(random_id.getrandom.hex)}"
  description = "service account for nodes"
}


resource "yandex_resourcemanager_folder_iam_member" "k8s_sa_member" {
  folder_id  = var.folder_id
  role       = "editor"
  members    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
  depends_on = [yandex_iam_service_account.k8s_sa]
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_node_sa_member" {
  folder_id  = var.folder_id
  role       = "editor"
  members    = "serviceAccount:${yandex_iam_service_account.k8s_node_sa.id}"
  depends_on = [yandex_iam_service_account.k8s_node_sa]
}


resource "yandex_kubernetes_cluster" "k8s" {
  name               = "k8s-${lower(random_id.getrandom.hex)}"
  description        = "somewhat cluster"
  folder_id          = var.folder_id
  network_id         = data.yandex_vpc_network.default.id
  cluster_ipv4_range = "10.217.0.0/18"
  service_ipv4_range = "10.218.0.0/18"
  master {
    regional {
      region = "ru-central1"
      location {
        zone      = "ru-central1-a"
        subnet_id = var.zone_a_subnet_id
      }
      location {
        zone      = "ru-central1-b"
        subnet_id = var.zone_b_subnet_id
      }
      location {
        zone      = "ru-central1-c"
        subnet_id = var.zone_c_subnet_id
      }
    }

    version   = "1.16"
    public_ip = true


  }
  service_account_id      = yandex_iam_service_account.k8s_sa.id
  node_service_account_id = yandex_iam_service_account.k8s_node_sa.id
  release_channel         = "RAPID"
  depends_on              = [yandex_resourcemanager_folder_iam_member.k8s_node_sa_member, yandex_resourcemanager_folder_iam_member.k8s_sa_member]

}
resource "yandex_kubernetes_node_group" "production_ng" {
  cluster_id  = yandex_kubernetes_cluster.k8s.id
  name        = "pe-ng-${lower(random_id.getrandom.hex)}"
  description = "description"
  version     = "1.16"

  labels = {
    "elasticsearch" = "true"
    "preemptible"   = "true"
  }
  //support for taints coming soon, stay tuned
  instance_template {
    platform_id = "standard-v2"
    nat         = true

    resources {
      memory = 24
      cores  = 8
    }

    scheduling_policy {
      preemptible = true
    }

    boot_disk {
      type = "network-ssd"
      size = 150
    }
  }

  scale_policy {
    # fixed_scale {
    #   size = 1
    # }
    auto_scale {
      min     = 1
      max     = 5
      initial = 1
    }
  }

  allocation_policy {
    //multizone workers does not suppor autoscaling
    # location {
    #   zone      = "ru-central1-a"
    #   subnet_id = var.zone_a_subnet_id
    # }
    # location {
    #   zone      = "ru-central1-b"
    #   subnet_id = var.zone_b_subnet_id
    # }
    location {
      zone      = "ru-central1-c"
      subnet_id = var.zone_c_subnet_id
    }
  }
  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "sunday"
      start_time = "04:00"
      duration   = "1h"
    }

    maintenance_window {
      day        = "wednesday"
      start_time = "02:00"
      duration   = "1h10m"
    }
  }
  depends_on = [yandex_resourcemanager_folder_iam_member.k8s_node_sa_member, yandex_resourcemanager_folder_iam_member.k8s_sa_member]
}

