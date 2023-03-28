variable "ingress_security_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "Allow from Personal CIDR block"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow SSH from Personal CIDR block"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  validation {
    condition = alltrue([
      for o in var.ingress_security_rules : o.protocol != "-1"
    ])
    error_message = "Protocol can't be -1 (all)"
  }
}
