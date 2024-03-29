variable "account_ids" {
  type    = list(string)
  default = ["${env("account_ids")}"]
}

variable "ami_prefix" {
  type    = string
  default = "CIS_WindowsServer_2019_EKS_Optimized"
}

variable "ami_version" {
  type    = string
  default = "${env("ami_version")}"
}

variable "ansible_winrm_server_cert_validation" {
  type    = string
  default = "ignore"
}

variable "assessment_template_arn" {
  type    = string
  default = "${env("assessment_template_arn")}"
}

variable "aws_ecr_account_id" {
  type    = string
  default = "${env("aws_ecr_account_id")}"
}

variable "base_ami_filter" {
  type    = string
  default = "Windows_Server-2019-English-Core-EKS_Optimized*"
}

variable "base_ami_owner" {
  type    = string
  default = "999352223265"
}

variable "cert_patches_bucket" {
  type    = string
  default = "${env("cert_patches_bucket")}"
}

variable "disable_stop_instance" {
  type    = string
  default = "false"
}

variable "exporter_key" {
  type    = string
  default = "${env("exporter_key")}"
}

variable "exporter_version" {
  type    = string
  default = "${env("exporter_version")}"
}

variable "force_delete_snapshot" {
  type    = string
  default = "${env("force_delete_snapshot")}"
}

variable "force_deregister" {
  type    = string
  default = "${env("force_deregister")}"
}

variable "input_ami_version" {
  type    = string
  default = "5.1.0"
}

variable "inspector_report_bucket" {
  type    = string
  default = "${env("inspector_report_bucket")}"
}

variable "inspector_report_bucket_key" {
  type    = string
  default = "${env("inspector_report_bucket_key")}"
}

variable "install_mps" {
  type    = string
  default = "true"
}

variable "installers_bucket" {
  type    = string
  default = "${env("installers_bucket")}"
}

variable "kms_key_id" {
  type    = string
  default = "${env("kms_key_id")}"
}

variable "promtail_bucket_key" {
  type    = string
  default = "${env("promtail_bucket_key")}"
}

variable "promtail_version" {
  type    = string
  default = "${env("promtail_version")}"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "root_volume_size" {
  type    = string
  default = "100"
}

variable "s3_encryption" {
  type    = string
  default = "${env("s3_encryption")}"
}

variable "security_group_id" {
  type    = string
  default = "${env("security_group_id")}"
}

variable "subnet_id" {
  type    = string
  default = "${env("subnet_id")}"
}

variable "vpc_id" {
  type    = string
  default = "${env("vpc_id")}"
}

data "amazon-ami" "ami" {
  filters = {
    name = "${var.base_ami_filter}"
  }
  most_recent = true
  owners      = ["${var.base_ami_owner}"]
  region      = "${var.region}"
}

packer {
  required_plugins {
    packer-plugin-amazon = {
      version = ">= 1.2.5"
      source = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ami" {
  ami_name                    = "${var.ami_prefix}_${var.ami_version}_${formatdate("YYYYMMDD", timestamp())}"
  #ami_users                   = "${var.account_ids}"
  associate_public_ip_address = true
  communicator                = "winrm"
  disable_stop_instance       = "${var.disable_stop_instance}"
  encrypt_boot                = true
  # fast_launch {
  #   enable_fast_launch    = true
  #   max_parallel_launches = 7
  #   template_name         = "ec2FastLaunch_infra"
  # }
  force_delete_snapshot = "${var.force_delete_snapshot}"
  force_deregister      = "${var.force_deregister}"
  iam_instance_profile  = "Packer_AMI_Creation_Permissions_Role"
  instance_type         = "t3.2xlarge"
  kms_key_id            = "${var.kms_key_id}"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    encrypted             = true
    volume_size           = "${var.root_volume_size}"
    volume_type           = "gp3"
  }
  region = "${var.region}"
  run_tags = {
    Name    = "Packer Build"
    Purpose = "Packer Build"
  }
  security_group_id = "${var.security_group_id}"
  source_ami        = "${data.amazon-ami.ami.id}"
  subnet_id         = "${var.subnet_id}"
  tags = {
    Base_AMI_Name       = "{{ .SourceAMIName }}"
    Build_At            = "${timestamp()}"
    Build_Date          = "${formatdate("YYYY-MM-DD", timestamp())}"
    Build_Time          = "${formatdate("HH:mmaa", timestamp())}"
    Hardened            = "yes"
    Hardening_Benchmark = "CIS Level 1"
    Name                = "${var.ami_prefix}_${var.ami_version}-${formatdate("YYYY-MM-DD", timestamp())}"
    OS_Version          = "WindowsServer2019"
    Purpose             = "EKS Windows Nodes"
    "RB:ECS:CostCenter" = "537301"
    "RB:ECS:Tenant"     = "shared"
    Release             = "${var.ami_version}"
  }
  user_data_file = "main/AWS_EC2_WinRM_Setup.ps1"
  vpc_id         = "${var.vpc_id}"
  winrm_insecure = true
  winrm_timeout  = "15m"
  winrm_use_ntlm = true
  winrm_use_ssl  = true
  winrm_username = "Administrator"
}

build {
  sources = ["source.amazon-ebs.ami"]

  provisioner "powershell" {
    scripts = ["main/AWS_EC2LaunchV1_Setup.ps1"]
  }

  provisioner "powershell" {
    scripts = ["main/Tool_Choco_Packages.ps1"]
  }

  provisioner "powershell" {
    environment_vars = ["CERTPatchesBucket=${var.cert_patches_bucket}"]
    pause_before     = "10s"
    scripts          = ["main/Bosch_Cert_Advisory_Patching.ps1"]
  }

  provisioner "ansible" {
    extra_arguments = ["-e", "ansible_winrm_server_cert_validation=${var.ansible_winrm_server_cert_validation}"]
    pause_before    = "1m0s"
    playbook_file   = "CIS-Windows-Ansible/playbook.yaml"
    roles_path      = "CIS-Windows-Ansible/CIS-Windows-2019-Ansible"
    use_proxy       = false
    user            = "Administrator"
  }

  provisioner "powershell" {
    environment_vars = ["INSTALLERS_BUCKET=${var.installers_bucket}", "EXPORTER_BUCKET_KEY=${var.exporter_key}", "EXPORTER_VERSION=${var.exporter_version}", "REGION=${var.region}"]
    pause_before     = "30s"
    scripts          = ["main/Tool_Windows_Exporter.ps1"]
  }

  provisioner "powershell" {
    environment_vars = ["INSTALLERS_BUCKET=${var.installers_bucket}", "PROMTAIL_BUCKET_KEY=${var.promtail_bucket_key}", "PROMTAIL_VERSION=${var.promtail_version}", "REGION=${var.region}"]
    pause_before     = "30s"
    scripts          = ["main/Tool_Promtail.ps1"]
  }

  provisioner "powershell" {
    environment_vars = ["Install_MPS=${var.install_mps}"]
    scripts          = ["main/Tool_TrendMicro_Agent.ps1"]
  }

  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"&amp; {Write-Output 'Machine restarted.'}\""
    restart_timeout       = "10m"
  }

  provisioner "file" {
    destination  = "C:/Temp/"
    max_retries  = "3"
    pause_before = "30s"
    source       = "main/Tests_Installed_Tools.ps1"
  }

  provisioner "powershell" {
    inline       = ["C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule", "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SysprepInstance.ps1 -NoShutdown"]
    pause_before = "30s"
  }

  post-processor "manifest" {
    output = "main/manifest.json"
  }
}
