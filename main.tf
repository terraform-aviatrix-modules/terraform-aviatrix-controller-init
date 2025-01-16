#First login, obtain CID.
resource "terracurl_request" "first_controller_login" {
  name            = "controller_login"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  destroy_url     = var.destroy_url
  destroy_method  = "GET"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "login",
    "username" : "admin",
    "password" : var.controller_private_ip,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 120
  retry_interval = 10

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to login to the controller: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }
}

#Set admin email address
resource "terracurl_request" "set_admin_email" {
  name            = "set_admin_email"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  destroy_url     = var.destroy_url
  destroy_method  = "GET"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "add_admin_email_addr",
    "CID" : local.init_cid,
    "admin_email" : var.controller_admin_email,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 3
  retry_interval = 3

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to set admin email address: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }
}

#Set notification email
resource "terracurl_request" "set_notification_email" {
  name            = "set_notification_email"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  destroy_url     = var.destroy_url
  destroy_method  = "GET"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "add_notif_email_addr",
    "CID" : local.init_cid
    "notif_email_args" : jsonencode({
      "admin_alert" : { "address" : var.controller_admin_email }
    })
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 3
  retry_interval = 3

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to set notification email: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [terracurl_request.set_admin_email]
}

#Set customer ID
resource "terracurl_request" "set_customer_id" {
  name            = "set_customer_id"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  destroy_url     = var.destroy_url
  destroy_method  = "GET"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "setup_customer_id",
    "CID" : local.init_cid
    "customer_id" : var.customer_id,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 3
  retry_interval = 3

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to set customer id: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [terracurl_request.set_notification_email]
}

#Set admin password
resource "terracurl_request" "set_admin_password" {
  name            = "set_admin_password"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  destroy_url     = var.destroy_url
  destroy_method  = "GET"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "edit_account_user",
    "CID" : local.init_cid
    "username" : "admin",
    "what" : "password",
    "old_password" : var.controller_private_ip,
    "new_password" : var.controller_admin_password,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 3
  retry_interval = 3

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to set admin password: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [terracurl_request.set_customer_id]
}

#Initialize controller
resource "terracurl_request" "controller_initial_setup" {
  name            = "controller_initial_setup"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  destroy_url     = var.destroy_url
  destroy_method  = "GET"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "initial_setup",
    "CID" : local.init_cid
    "subaction" : "run",
    "target_version" : var.controller_version,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  timeout = 300

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    terracurl_request.set_admin_email,
    terracurl_request.set_admin_password,
    terracurl_request.set_notification_email,
    terracurl_request.set_customer_id,
  ]
}

#Wait for initialization
resource "time_sleep" "wait_for_setup" {
  create_duration = var.wait_for_setup_duration

  depends_on = [terracurl_request.controller_initial_setup]
}

#Check everything is up and running
resource "terracurl_request" "verify_complete" {
  name            = "verify_complete"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  destroy_url     = var.destroy_url
  destroy_method  = "GET"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "login",
    "username" : "admin",
    "password" : var.controller_admin_password,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 10
  retry_interval = 10

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to login after initialization: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [
    time_sleep.wait_for_setup
  ]
}
