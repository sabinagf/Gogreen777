variable "public_subnets" {
  type = map(object({
    name              = string,
    cidr_block        = string,
    availability_zone = string
  }))

  default = {
  }
}
variable "private_subnets" {
  type = map(object({
    name              = string,
    cidr_block        = string,
    availability_zone = string
  }))

  default = {
  }
}
variable "prefix" {
  type    = string
  default = "Green"

}
variable "nat-rta" {
  type = map(object({
    route_table_id = string,
    subnet_id      = string
  }))
  default = {
  }
}


variable "key_name" {
  type    = string
  default = ""
}

# variable "aws_iam_virtual_mfa_device" {
#   type = map(object({
#     user_name = string
#   }))
#   default = {
#   }
# }
# AWS IAM policy for the MFA device. If not provided a generic one will be created.

# variable "iam_user_names" {
#   type    = list(string)
#   default = ["sysadmin1", "sysadmin2"]
# }
#############################################################
variable "max_password_age" {
  type        = number
  default     = 90
  description = "The number of days that an user password is valid."
}

variable "password_reuse_prevention" {
  type        = number
  default     = 3
  description = "The number of previous passwords that users are prevented from reusing."
}

variable "hard_expiry" {
  type        = string
  default     = false
  description = "Whether users are prevented from setting a new password after their password"
}

variable "iam_user" {
  type = map(object({
    name = string,
    tags = map(string)
  }))
  default = {

  }
}
variable "known_hosts" {
  type    = string
  default = "0.0.0.0/0"
}
variable "domain_name" {
  type    = string
  default = "ziyotekgogreen.net"
}
