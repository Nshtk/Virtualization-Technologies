locals {
  username = "docker"
  ssh_key_path = "~/.ssh/id_rsa.pub"
  network_name = "docker-vm-network"
  subnet_name = "docker-vm-network-subnet-a"
  vm_name = "docker-vm"
  vm_image_id = "fd8o9coe41hlf4uc194g"
}

resource "yandex_iam_service_account" "sa" {
  folder_id = var.folder_id
  name      = "tf-sa-docker"
}
resource "yandex_resourcemanager_folder_iam_member" "registry-sa-role-images-puller" { 
  folder_id = var.folder_id
  role      = "container-registry.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_container_registry" "docker-registry" {
  name = "docker-registry"
  folder_id = var.folder_id
}
resource "yandex_vpc_network" "docker-vm-network" {
  name = local.network_name
}
resource "yandex_vpc_subnet" "docker-vm-network-subnet-a" {
  name           = local.subnet_name
  zone           = var.default_zone
  v4_cidr_blocks = ["192.168.1.0/24"]
  network_id     = yandex_vpc_network.docker-vm-network.id
}

resource "yandex_compute_disk" "boot-disk" {
  name     = "bootvmdisk"
  type     = "network-hdd"
  zone     = var.default_zone
  size     = "10"
  image_id = local.vm_image_id
}
resource "yandex_compute_instance" "docker-vm" {
  name               = local.vm_name
  platform_id        = "standard-v3"
  zone               = var.default_zone
  service_account_id = "${yandex_iam_service_account.sa.id}"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.boot-disk.id
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.docker-vm-network-subnet-a.id}"
    nat       = true
  }
  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${local.username}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh_authorized_keys:\n      - ${file("${local.ssh_key_path}")}"
  }
}