variable "node_count" {
  description = "Number of EC2 instances for the cluster"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "Instance type for the cluster nodes. t4g.small (arm64) is the cheapest type meeting kubeadm's 2 vCPU / 2 GiB minimum; use t3a.small if you need x86."
  type        = string
  default     = "t4g.small"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to reach SSH and the Kubernetes API from outside the cluster. Restrict this to your own IP (e.g. 203.0.113.7/32) rather than the default."
  type        = string
  default     = "0.0.0.0/0"
}

variable "project" {
  description = "Project tag applied to all resources"
  type        = string
  default     = "aws-k8s-terraform"
}
