# add outputs here
// filename: outputs.tf

output "network_id" { value = local.network_id }
output "subnet_ids" { value = local.all_subnet_ids }
output "internal_cidrs" { value = local.all_internal_cidrs }

output "instance_name" { value = google_compute_instance.vm.name }
output "instance_self_link" { value = google_compute_instance.vm.self_link }
output "internal_ip" { value = google_compute_instance.vm.network_interface[0].network_ip }

output "external_ip" {
  value = try(
    google_compute_address.static[0].address,
    google_compute_instance.vm.network_interface[0].access_config[0].nat_ip,
    null
  )
}

output "service_account_email" {
  value = local.service_account_email
}

output "dns_zone_nameservers" {
  value = try(google_dns_managed_zone.zone[0].name_servers, null)
}

