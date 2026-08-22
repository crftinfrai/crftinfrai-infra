variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "aws_profile" {
  type    = string
  default = null
}

variable "environment" {
  type        = string
  description = "Environment name for tagging (e.g., dev/stg/prod)."
  default     = "prod"
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for naming resources."
  default     = "crft"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged with default tags."
  default     = {}
}

# -------------------------
# Network
# -------------------------
variable "network_mode" {
  type        = string
  description = "Network mode: create a minimal VPC or use existing."
  default     = "create"

  validation {
    condition     = contains(["create", "existing"], var.network_mode)
    error_message = "network_mode must be 'create' or 'existing'."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC when network_mode=create."
  default     = "10.60.0.0/16"
}

variable "create_subnet_cidrs" {
  type        = list(string)
  description = "Subnet CIDRs when network_mode=create."
  default     = ["10.60.1.0/24", "10.60.2.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "AZs for created subnets. If empty, the module picks the first N AZs automatically."
  default     = []
}

variable "existing_vpc_id" {
  type        = string
  description = "Existing VPC id when network_mode=existing."
  default     = null
}

variable "existing_subnet_ids" {
  type        = list(string)
  description = "Existing subnet ids when network_mode=existing."
  default     = []
}

# -------------------------
# Cluster
# -------------------------
variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster."
  default     = "crft-eks"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for EKS (e.g., 1.29). If null, AWS default is used."
  default     = null
}

# Secure-by-default for public repo: private endpoint ON, public OFF
variable "endpoint_public_access" {
  type        = bool
  description = "Enable public access to the EKS API endpoint."
  default     = false
}

variable "endpoint_private_access" {
  type        = bool
  description = "Enable private access to the EKS API endpoint."
  default     = true
}

variable "api_public_access_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to access public EKS endpoint (only used if endpoint_public_access=true)."
  default     = ["0.0.0.0/0"]
}

# -------------------------
# Node group
# -------------------------
variable "node_desired_size" {
  type        = number
  description = "Desired node count."
  default     = 3
}

variable "node_min_size" {
  type        = number
  description = "Minimum node count."
  default     = 1
}

variable "node_max_size" {
  type        = number
  description = "Maximum node count."
  default     = 6
}

variable "node_instance_types" {
  type        = list(string)
  description = "EC2 instance types for the node group."
  default     = ["t3.large"]
}

variable "node_disk_size" {
  type        = number
  description = "Disk size in GiB for nodes."
  default     = 100
}

variable "node_ami_type" {
  type        = string
  description = "EKS node AMI type."
  default     = "AL2_x86_64"
}

variable "node_capacity_type" {
  type        = string
  description = "ON_DEMAND or SPOT."
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_labels" {
  type        = map(string)
  description = "Kubernetes labels applied to the node group."
  default     = {}
}
