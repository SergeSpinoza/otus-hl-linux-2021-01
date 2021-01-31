terraform {
  required_providers {
    ah = {
      source  = "advancedhosting/ah"
      version = "0.1.3"
    }
  }
}

provider "ah" {
  access_token = var.access_token
}

resource "ah_ssh_key" "deploy_ssh_key" {
  name       = "Deploy ssh key"
  public_key = file(var.public_key_path)
}

resource "ah_cloud_server" "nginx_server" {
  name       = "Nginx server"
  datacenter = "ams1"
  image      = "ubuntu-20_04-x64"
  product    = "start-xs"
  ssh_keys   = [ah_ssh_key.deploy_ssh_key.fingerprint]
  depends_on = [ah_ssh_key.deploy_ssh_key]
}

resource "null_resource" "nginx" {
  provisioner "remote-exec" {
    inline = ["sleep 1"]

    connection {
      host        = ah_cloud_server.nginx_server.ips.0.ip_address
      type        = "ssh"
      user        = "adminroot"
      private_key = file(var.private_key_path)
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u adminroot -i '${ah_cloud_server.nginx_server.ips.0.ip_address},' --private-key ${var.private_key_path} -- provision.yml"
  }

  depends_on = [ah_cloud_server.nginx_server]
}

