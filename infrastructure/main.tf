# Модуль управления виртуальными сетями [yc-vpc]
module "yc-vpc" {
  source              = "github.com/terraform-yc-modules/terraform-yc-vpc.git"
  network_name        = "k8s-network"
  network_description = "K8s network created for diplom"
  private_subnets = [{
    name           = "subnet-1"
    zone           = "ru-central1-a"
    v4_cidr_blocks = ["10.10.0.0/24"]
    }
  ]
}

# Модуль Managed Service for Kubernetes [kube]
module "kube" {
  source     = "github.com/terraform-yc-modules/terraform-yc-kubernetes.git"
  network_id = module.yc-vpc.vpc_id

  master_locations = [
    for s in module.yc-vpc.private_subnets :
    {
      zone      = s.zone,
      subnet_id = s.subnet_id
    }
  ]

  master_maintenance_windows = [
    {
      day        = "monday"
      start_time = "23:00"
      duration   = "3h"
    }
  ]

  node_groups = {
    "yc-k8s-ng-01" = {
      description = "Kubernetes nodes group 01"
      auto_scale = {
        min     = 2
        max     = 4
        initial = 2
      }
      node_labels = {
        role        = "worker-node-01"
        environment = "dev"
      }

      max_expansion   = 1
      max_unavailable = 1
    }
  }

  node_groups_defaults = {
    platform_id   = "standard-v3"
    node_cores    = 2
    node_memory   = 4
    node_gpus     = 0
    core_fraction = 100
    disk_type     = "network-ssd"
    disk_size     = 30
    preemptible   = false
    nat           = false
    ipv4          = true
    ipv6          = false
  }

  release_channel = "STABLE"
}
