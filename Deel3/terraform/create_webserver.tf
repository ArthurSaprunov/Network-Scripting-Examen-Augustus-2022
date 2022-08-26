
resource "vsphere_virtual_machine" "webserver" {
  count = 2
  name             = "web0${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder = vsphere_folder.poc.path

  num_cpus = 1
  memory   = 1024
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
	label = "disk0"
	size = 10
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "web0${count.index + 1}"
        domain    = "labo09.local"
      }

      network_interface {
        ipv4_address = "192.168.50.${count.index + 20}"
        ipv4_netmask = 24
      }

      ipv4_gateway = "192.168.50.1"
    }
  }
}
