#====================#
# vCenter connection #
#====================#

variable "vsphere_user" {
  description = "vSphere user name"
}

variable "vsphere_password" {
  description = "vSphere password"
}

variable "vsphere_vcenter" {
  description = "vCenter server FQDN or IP"

}

variable "vsphere_unverified_ssl" {
  description = "Is the vCenter using a self signed certificate (true/false)"
  default = true
}

variable "vsphere_datacenter" {
  description = "vSphere datacenter"
  default = "StudentDatacenter"
}

variable "vsphere_cluster" {
  description = "vSphere cluster"
  default     = "StudentCluster "
}



#=========================#
# vSphere virtual machine #
#=========================#

variable "vm_datastore" {
  description = "Datastore used for the vSphere virtual machines"
}

variable "vm_network" {
  description = "Network used for the vSphere virtual machines"
}

variable "vm_template" {
  description = "Template used to create the vSphere virtual machines"
}

variable "vm_name" {
  description = "The name of the vSphere virtual machines and the hostname of the machine"
}	

variable "vm_domain" {
  description = "Domain for the vSphere virtual machine"
}

variable "vm_ip" {
  description = "Ip used for the vSpgere virtual machine"
}

variable "vm_netmask" {
  description = "Netmask used for the vSphere virtual machine (example: 24)"
}


