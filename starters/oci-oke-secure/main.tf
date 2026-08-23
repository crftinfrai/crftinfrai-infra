resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr
  display_name   = "vcn-${var.oke_name}"
}

resource "oci_core_subnet" "subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn.id
  cidr_block                 = var.subnet_cidr
  display_name               = "snet-oke"
  prohibit_public_ip_on_vnic = true
  dns_label                  = "okelab"
}

# OKE Cluster
resource "oci_containerengine_cluster" "oke" {
  compartment_id     = var.compartment_ocid
  name               = var.oke_name
  vcn_id             = oci_core_vcn.vcn.id
  kubernetes_version = "v1.28.2"
  endpoint_config {
    is_public_ip_enabled = false
    subnet_id            = oci_core_subnet.subnet.id
  }
}

resource "oci_containerengine_node_pool" "np" {
  compartment_id     = var.compartment_ocid
  cluster_id         = oci_containerengine_cluster.oke.id
  name               = "${var.oke_name}-pool"
  kubernetes_version = oci_containerengine_cluster.oke.kubernetes_version
  node_config_details {
    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = oci_core_subnet.subnet.id
    }
    size = 2
  }
  node_shape = var.node_shape
  node_shape_config {
    memory_in_gbs = var.node_memory_gbs
    ocpus         = var.node_ocpus
  }
}

output "vcn_id" { value = oci_core_vcn.vcn.id }
output "subnet_id" { value = oci_core_subnet.subnet.id }
output "oke_id" { value = oci_containerengine_cluster.oke.id }
