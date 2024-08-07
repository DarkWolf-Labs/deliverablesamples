module "vpc" {
  source     = "../../modules/net-vpc"
  count      = local.use_shared_vpc ? 0 : 1
  project_id = module.project.project_id
  name       = "${var.prefix}-vpc"
  subnets = [
    {
      ip_cidr_range = "10.0.0.0/20"
      name          = "${var.prefix}-subnet"
      region        = var.region
    }
  ]
}

module "vpc-firewall" {
  source     = "../../modules/net-vpc-firewall"
  count      = local.use_shared_vpc ? 0 : 1
  project_id = module.project.project_id
  network    = module.vpc[0].name
  default_rules_config = {
    admin_ranges = ["10.0.0.0/20"]
  }
  ingress_rules = {
    ("${var.prefix}-iap") = {
      description   = "Enable SSH from IAP target VMs."
      source_ranges = ["35.235.240.0/20"]
      targets       = ["iap-ssh"]
      rules         = [{ protocol = "tcp", ports = [22] }]
    }
    ("${var.prefix}-matrix") = {
      description = "Inbound ports required for matrix Server"
      target      = ["matrix-server"]
      rules = [
        {
          source_ranges = ["10.0.0.0/20"]
          protocol      = "tcp",
          ports = [
            80,
            443
          ]
        }
      ]
    },
    ("${var.prefix}-openvpn") = {
      description = "Inbound ports required for openvpn"
      target      = ["openvpn-server"]
      rules = [
        {
          source_ranges = ["10.0.0.0/20", "35.235.240.0/20"]
          protocol      = "tcp",
          ports = [
            80,
            443
          ]
        },
        {
          source_ranges = ["0.0.0.0/0"]
          protocol      = "udp",
          ports = [
            1194
          ]
        }
      ]
    }
  }
}

module "cloudnat" {
  source         = "../../modules/net-cloudnat"
  count          = local.use_shared_vpc ? 0 : 1
  project_id     = module.project.project_id
  name           = "${var.prefix}-default"
  region         = var.region
  router_network = module.vpc[0].name
}

resource "google_project_iam_member" "shared_vpc" {
  count   = local.use_shared_vpc ? 1 : 0
  project = var.vpc_config.host_project
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${module.project.service_accounts.robots.notebooks}"
}