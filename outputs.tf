output "node_public_ips" {
  description = "Public IPs of the cluster nodes, keyed by Name tag"
  value       = { for i in aws_instance.k8s_node : i.tags.Name => i.public_ip }
}

output "node_private_ips" {
  description = "Private IPs of the cluster nodes, keyed by Name tag"
  value       = { for i in aws_instance.k8s_node : i.tags.Name => i.private_ip }
}

output "ssh_commands" {
  description = "Ready-to-use SSH commands for each node"
  value = [
    for i in aws_instance.k8s_node :
    "ssh -i ${var.project}-key.pem ubuntu@${i.public_ip}"
  ]
}
