# terraform-aviatrix-controller-init

### Description
This module initializes a freshly deployed controller. It requires the usage of a g3 based controller image, in order for the API v2 operations to function properly.

### Compatibility
Module version | Terraform version
:--- | :---
v1.0.4 | >= 1.3

### Usage Example
```hcl
module "controller_init" {
  source  = "terraform-aviatrix-modules/controller-init/aviatrix"
  version = "v1.0.4"

  controller_public_ip      = "1.2.3.4"
  controller_private_ip     = "10.1.1.123"
  controller_admin_email    = "admin@domain.com"
  controller_admin_password = "mysecurepassword"
  customer_id               = "aviatrix-abu-123456"
}
```

### Variables
The following variables are required:

key | value
:--- | :---
controller_public_ip | Public IP of the controller
controller_private_ip | Private IP of the controller
controller_admin_email | Email address for the admin
controller_admin_password | Desired password for the controller
customer_id | Customer_id for the controller (License)

The following variables are optional:

key | default | value 
:---|:---|:---
controller_version | latest | The desired controller version
wait_for_setup_duration | 10m | Wait timer for controller to come up after initialization

### Outputs
This module will return the following outputs:

key | description
:---|:---
controller_setup_result | Response body of the controller initialization API call




