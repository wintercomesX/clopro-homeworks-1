# Create VPC
resource "yandex_vpc_network" "vpc" {
  folder_id = "b1gghnpp51joeriep6bo"
  name      = "my-vpc"
  labels = {
    environment = "dev"
  }
}

# Create public subnet
resource "yandex_vpc_subnet" "public" {
  folder_id       = "b1gghnpp51joeriep6bo"
  network_id      = yandex_vpc_network.vpc.id
  name            = "public"
  zone            = var.region
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Create route table for private subnet
resource "yandex_vpc_route_table" "private_route_table" {
  name       = "private-route-table"
  network_id = yandex_vpc_network.vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}

# Create private subnet and associate route table
resource "yandex_vpc_subnet" "private" {
  folder_id       = "b1gghnpp51joeriep6bo"
  network_id      = yandex_vpc_network.vpc.id
  name            = "private"
  zone            = var.region
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id  = yandex_vpc_route_table.private_route_table.id
}

# NAT Instance
resource "yandex_compute_instance" "nat" {
  name        = "nat-instance"
  zone        = var.region
  platform_id = "standard-v1"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"  # Static IP for NAT
    nat        = true
  }
  metadata = {
    serial-port-enable = 1
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

# Public VM
resource "yandex_compute_instance" "public_vm" {
  name        = "public-vm"
  zone        = var.region
  platform_id = "standard-v1"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd8aus3bfglr6dg9hsbk"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }
  metadata = {
    serial-port-enable = 1
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

# Private VM
resource "yandex_compute_instance" "private_vm" {
  name        = "private-vm"
  zone        = var.region
  platform_id = "standard-v1"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd8aus3bfglr6dg9hsbk"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false
  }
  metadata = {
    serial-port-enable = 1
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}
