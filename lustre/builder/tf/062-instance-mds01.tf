#### INSTANCE Client01 ####
#
# Create instance
#
resource "openstack_compute_instance_v2" "mds01" {
  name        = var.node03
  image_name  = var.image
  flavor_name = var.flavor
  key_pair    = var.jenkinskey
  user_data   = file("cloud-init")
  network {
    port = openstack_networking_port_v2.mds01_port.id
  }
}

# Create network port
resource "openstack_networking_port_v2" "mds01_port" {
  name           = var.lustre_mds01_port
  network_id     = var.lustre_net
  admin_state_up = true
  security_group_ids = [
    var.lustre_sg,
  ]
  fixed_ip {
    subnet_id = var.lustre_subnet
  }
}

# Create floating ip
resource "openstack_networking_floatingip_v2" "mds01_floating" {
  pool = var.ext_net
}

# Attach floating ip to instance
resource "openstack_compute_floatingip_associate_v2" "mds01_floating_attach" {
  floating_ip = openstack_networking_floatingip_v2.mds01_floating.address
  instance_id = openstack_compute_instance_v2.mds01.id
}

# Create volume
resource "openstack_blockstorage_volume_v2" "mds01_volume01" {
  name = var.mds_volume01
  size = var.mds_size
}

# Attach volume to instance instance db
resource "openstack_compute_volume_attach_v2" "mds01_volume01_attach" {
  instance_id = openstack_compute_instance_v2.mds01.id
  volume_id   = openstack_blockstorage_volume_v2.mds01_volume01.id
}

resource "openstack_blockstorage_volume_v2" "mds01_volume02" {
  name = var.mds_volume02
  size = var.mds_size
}

resource "openstack_compute_volume_attach_v2" "mds01_volume02_attach" {
  instance_id = openstack_compute_instance_v2.mds01.id
  volume_id   = openstack_blockstorage_volume_v2.mds01_volume02.id
}
