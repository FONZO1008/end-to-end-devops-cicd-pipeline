variable "image_tag" {
  description = "Docker image tag passed from Jenkins build number"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH. Set this to your Jenkins server IP e.g. 1.2.3.4/32"
  type        = string
  default     = "0.0.0.0/0"   # <-- Override this. Do not leave open in production.
}
