# Oracle Cloud Infrastructure modules

Reusable OCI Terraform modules:

- `oci_autonomous_db` — Autonomous Database.
- `oci_compute` — Compute instance, network, security list, and optional DNS.
- `oci_db` — PostgreSQL database system.
- `oci_functions` — Functions application and function.
- `oci_object_storage` — Object Storage bucket.
- `oke` — OKE cluster and node pool.

OCI modules accept tenancy, compartment, user, fingerprint, and private-key
path inputs because the provider needs them. Provide those values through an
approved local profile or secret-management workflow, never source control.
