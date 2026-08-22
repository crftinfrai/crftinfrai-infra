// filename: main.tf

locals {
  create_net       = var.network_mode == "create"
  use_existing_net = var.network_mode == "existing"

  use_image_lookup = var.image_ocid == null || var.image_ocid == ""

  ssh_keys_str = join("\n", [for u in var.ssh_users : u.public_key])
  user_data_b64 = (
    var.user_data != "" ? base64encode(var.user_data) :
    (var.user_data_path != "" ? base64encode(file(var.user_data_path)) : null)
  )
}

# VCN/Subnet/IGW/RT
resource "oci_core_vcn" "vcn" {
  count          = local.create_net ? 1 : 0
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.name_prefix}-vcn"
}

resource "oci_core_internet_gateway" "igw" {
  count          = local.create_net ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn[0].id
  enabled        = true
  display_name   = "${var.name_prefix}-igw"
}

resource "oci_core_route_table" "rt" {
  count          = local.create_net ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn[0].id
  display_name   = "${var.name_prefix}-rt"
  route_rules {
    network_entity_id = oci_core_internet_gateway.igw[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "subnet" {
  count                      = local.create_net ? 1 : 0
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn[0].id
  cidr_block                 = var.subnet_cidr
  display_name               = "${var.name_prefix}-subnet"
  prohibit_public_ip_on_vnic = !var.assign_public_ip
  route_table_id             = oci_core_route_table.rt[0].id
  dns_label                  = replace(var.name_prefix, "/[^a-zA-Z0-9]/", "")
  security_list_ids          = [oci_core_security_list.sl[0].id]
}

# Security List
resource "oci_core_security_list" "sl" {
  count          = local.create_net ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn[0].id
  display_name   = "${var.name_prefix}-sl"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6" # tcp
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

# Chosen subnet id
locals {
  subnet_id = local.create_net ? oci_core_subnet.subnet[0].id : var.existing_subnet_id
}

# Image lookup (Ubuntu 22.04)
data "oci_core_images" "ubuntu" {
  count                    = local.use_image_lookup ? 1 : 0
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = var.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  final_image_ocid = local.use_image_lookup ? data.oci_core_images.ubuntu[0].images[0].id : var.image_ocid
}

# Reserved Public IP (optional)
resource "oci_core_public_ip" "reserved" {
  count          = var.assign_public_ip && var.allocate_reserved_ip ? 1 : 0
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "${var.name_prefix}-public-ip"
}

# Instance
resource "oci_core_instance" "vm" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  display_name        = var.instance_name
  shape               = "VM.Standard.E4.Flex"

  shape_config {
    ocpus         = var.shape_ocpus
    memory_in_gbs = var.shape_memory_gbs
  }

  source_details {
    source_type             = "image"
    image_id                = local.final_image_ocid
    boot_volume_size_in_gbs = var.boot_volume_size_gb
  }

  create_vnic_details {
    subnet_id        = local.subnet_id
    assign_public_ip = var.assign_public_ip
    nsg_ids          = []
  }

  metadata = {
    ssh_authorized_keys = local.ssh_keys_str
    user_data           = local.user_data_b64
  }

  preserve_boot_volume = false
}

# Attach reserved public IP to primary VNIC (if created)
resource "oci_core_public_ip_assignment" "attach" {
  count         = var.assign_public_ip && var.allocate_reserved_ip ? 1 : 0
  public_ip_id  = oci_core_public_ip.reserved[0].id
  private_ip_id = oci_core_instance.vm.primary_private_ip_id
}

# OCI DNS (optional)
resource "oci_dns_zone" "zone" {
  count          = var.create_dns_zone ? 1 : 0
  compartment_id = var.compartment_ocid
  name           = var.root_domain
  zone_type      = "PRIMARY"
}

resource "oci_dns_rrset" "a_record" {
  count           = var.create_dns_record ? 1 : 0
  zone_name_or_id = var.create_dns_zone ? oci_dns_zone.zone[0].id : var.existing_zone_id
  domain          = "${var.subdomain}.${var.root_domain}"
  rtype           = "A"
  items = [{
    domain = "${var.subdomain}.${var.root_domain}"
    rtype  = "A"
    ttl    = 300
    rdata  = coalesce(try(oci_core_public_ip.reserved[0].ip_address, null), oci_core_instance.vm.public_ip)
  }]
}
