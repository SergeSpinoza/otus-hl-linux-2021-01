output "external_ip" {
  value = ah_cloud_server.nginx_server.ips.0.ip_address
}
