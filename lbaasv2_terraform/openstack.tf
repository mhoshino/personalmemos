provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "password"
  domain_id   = "default"
  auth_url    = "http://10.0.2.15/identity"
  region      = "RegionOne"
}

variable "instance_count" {
  default = "1"
}

variable "instance_prefix" {
  default = "test"
}

variable "image_name" {
  default = "cirros-0.3.5-x86_64-disk"
}

variable "flavor_id" {
  default = "1"
}

variable "instance_network_name" {
  default = "private"
}

variable "instance_subnet_id" {
  default = "22960f1c-2753-41b4-9c99-f44401121f3c"
}

variable "loadbalancer_name" {
  default = "test"
}

variable "vip_subnet_id" {
  default = "22960f1c-2753-41b4-9c99-f44401121f3c"
}

resource "openstack_compute_instance_v2" "instance" {
  count           = "${var.instance_count}"
  name            = "${format("%s_%d", var.instance_prefix, count.index)}"
  image_name      = "${var.image_name}"
  flavor_id       = "${var.flavor_id}"

  network {
    name = "${var.instance_network_name}"
  }
}

resource "openstack_lb_loadbalancer_v2" "loadbalancer" {
  name          = "${var.loadbalancer_name}"
  vip_subnet_id = "${var.vip_subnet_id}"
}

resource "openstack_lb_listener_v2" "listener" {
  name            = "${format("%s_listener",openstack_lb_loadbalancer_v2.loadbalancer.name)}"
  protocol        = "HTTP"
  protocol_port   = "80"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.loadbalancer.id}"
}

resource "openstack_lb_pool_v2" "pool" {
  name        = "${format("%s_pool", openstack_lb_loadbalancer_v2.loadbalancer.name)}"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${openstack_lb_listener_v2.listener.id}"
}

resource "openstack_lb_monitor_v2" "monitor" {
  name        = "${format("%s_monitor", openstack_lb_loadbalancer_v2.loadbalancer.name)}"
  pool_id     = "${openstack_lb_pool_v2.pool.id}"
  type        = "PING"
  delay       = "20"
  timeout     = "10"
  max_retries = "2"
}


resource "openstack_lb_member_v2" "member" {
  count         = "${var.instance_count}"
  name          = "${format("%s_member_%d", openstack_lb_loadbalancer_v2.loadbalancer.name, count.index)}"
  address       = "${element(openstack_compute_instance_v2.instance.*.network.0.fixed_ip_v4, count.index)}"
  subnet_id     = "${var.instance_subnet_id}"
  protocol_port = "80"
  pool_id       = "${openstack_lb_pool_v2.pool.id}"
}
