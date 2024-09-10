terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.120"
  # Настройка Бэкенда терраформ
  backend "s3" {
    endpoints = {
      s3       = "https://storage.yandexcloud.net"
      dynamodb = "https://docapi.serverless.yandexcloud.net/ru-central1/b1g9jen1tmj36jq121vc/etnr3khmp3eqtfokta8v"
    }
    bucket = "terraform-state-kazmaks"
    region = "ru-central1"
    key    = "production/terraform.tfstate"

    dynamodb_table = "tf-state-tb"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  }
}
