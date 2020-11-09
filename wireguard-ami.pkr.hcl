variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_secret_key" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = "us-west-1"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "wireguard" {
  access_key              = var.aws_access_key
  ami_description         = "Simple wireguard AMI"
  ami_name                = "wireguard-${local.timestamp}"
  ami_virtualization_type = "hvm"
  encrypt_boot            = true
  spot_instance_types     = ["t2.micro"]
  spot_price              = "auto"
  region                  = var.aws_region
  secret_key              = var.aws_secret_key
  source_ami_filter {
    filters = {
      architecture        = "x86_64"
      name                = "amzn2-ami-hvm-2.*-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_interface = "session_manager"
  ssh_username = "ec2-user"
  iam_instance_profile = "packer-build-instance-profile"
}

build {
  sources = ["source.amazon-ebs.wireguard"]

  provisioner "shell" {
    script = "./provision.sh"
  }
}
