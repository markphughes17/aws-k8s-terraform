# aws-k8s-terraform
terraform code to create resources for a sandbox k8s cluster in AWS - Claude used to generate

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.55.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.9.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.k8s_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.k8s](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.k8s](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.k8s_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.k8s](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [local_file.ssh_private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type for the cluster nodes. t4g.small (arm64) is the cheapest type meeting kubeadm's 2 vCPU / 2 GiB minimum; use t3a.small if you need x86. | `string` | `"t4g.small"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of EC2 instances for the cluster | `number` | `3` | no |
| <a name="input_project"></a> [project](#input\_project) | Project tag applied to all resources | `string` | `"aws-k8s-terraform"` | no |
| <a name="input_ssh_allowed_cidr"></a> [ssh\_allowed\_cidr](#input\_ssh\_allowed\_cidr) | CIDR allowed to reach SSH and the Kubernetes API from outside the cluster. Restrict this to your own IP (e.g. 203.0.113.7/32) rather than the default. | `string` | `"0.0.0.0/0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_node_private_ips"></a> [node\_private\_ips](#output\_node\_private\_ips) | Private IPs of the cluster nodes, keyed by Name tag |
| <a name="output_node_public_ips"></a> [node\_public\_ips](#output\_node\_public\_ips) | Public IPs of the cluster nodes, keyed by Name tag |
| <a name="output_ssh_commands"></a> [ssh\_commands](#output\_ssh\_commands) | Ready-to-use SSH commands for each node |
<!-- END_TF_DOCS -->