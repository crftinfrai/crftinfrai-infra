// filename: main.tf

locals {
  create_net = var.network_mode == "create"
}

# Network (create): VCN + subnets
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

resource "oci_core_subnet" "node" {
  count                      = local.create_net ? 1 : 0
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn[0].id
  cidr_block                 = var.node_subnet_cidr
  display_name               = "${var.name_prefix}-node-subnet"
  route_table_id             = oci_core_route_table.rt[0].id
  prohibit_public_ip_on_vnic = !var.assign_public_ip
}

resource "oci_core_subnet" "lb" {
  count                      = local.create_net ? 1 : 0
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn[0].id
  cidr_block                 = var.lb_subnet_cidr
  display_name               = "${var.name_prefix}-lb-subnet"
  route_table_id             = oci_core_route_table.rt[0].id
  prohibit_public_ip_on_vnic = false
}

locals {
  node_subnet_id = local.create_net ? oci_core_subnet.node[0].id : var.existing_node_subnet_id
  lb_subnet_id   = local.create_net ? oci_core_subnet.lb[0].id : var.existing_lb_subnet_id
}

# Cluster
resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_ocid
  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vcn_id             = local.create_net ? oci_core_vcn.vcn[0].id : var.existing_vcn_id
  endpoint_config {
    is_public_ip_enabled = var.api_public
    subnet_id            = local.lb_subnet_id
  }
  options {
    service_lb_subnet_ids = [local.lb_subnet_id]
  }
}

# Node Pool
resource "oci_containerengine_node_pool" "default" {
  compartment_id     = var.compartment_ocid
  cluster_id         = oci_containerengine_cluster.this.id
  name               = "${var.cluster_name}-np"
  kubernetes_version = var.kubernetes_version
  node_shape         = var.node_shape

  node_config_details {
    size = var.node_count
    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = local.node_subnet_id
    }
  }

  node_shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory_gbs
  }

  node_source_details {
    image_id    = var.node_image_ocid
    source_type = "image"
  }

  initial_node_labels {
    key   = "app"
    value = "crft"
  }
}
