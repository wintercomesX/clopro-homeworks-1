# outputs.tf

output "public_vm_ip" {
  description = "Public VM's IP address"
  value       = yandex_compute_instance.public_vm.network_interface[0].ip_address
}

output "private_vm_ip" {
  description = "Private VM's IP address"
  value       = yandex_compute_instance.private_vm.network_interface[0].ip_address
}
