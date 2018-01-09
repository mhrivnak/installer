module "etcd" {
  source = "../../modules/vmware/etcd"

  base_domain             = "${var.tectonic_base_domain}"
  cluster_name            = "${var.tectonic_cluster_name}"
  container_image         = "${var.tectonic_container_images["etcd"]}"
  core_public_keys        = ["${var.tectonic_vmware_ssh_authorized_key}"]
  dns_server              = "${var.tectonic_vmware_node_dns}"
  external_endpoints      = ["${compact(var.tectonic_etcd_servers)}"]
  gateways                = "${var.tectonic_vmware_etcd_gateways}"
  hostname                = "${var.tectonic_vmware_etcd_hostnames}"
  ign_etcd_crt_id_list    = "${module.ignition_masters.etcd_crt_id_list}"
  ign_etcd_dropin_id_list = "${module.ignition_masters.etcd_dropin_id_list}"
  instance_count          = "${var.tectonic_etcd_count }"
  ip_address              = "${var.tectonic_vmware_etcd_ip}"
  vm_disk_datastore       = "${var.tectonic_vmware_etcd_datastore}"
  vm_disk_template        = "${var.tectonic_vmware_vm_template}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  vm_memory               = "${var.tectonic_vmware_etcd_memory}"
  vm_network_labels       = "${var.tectonic_vmware_etcd_networks}"
  vm_vcpu                 = "${var.tectonic_vmware_etcd_vcpu}"
  vmware_clusters         = "${var.tectonic_vmware_etcd_clusters}"
  vmware_datacenters      = "${var.tectonic_vmware_etcd_datacenters}"
  vmware_folder           = "${vsphere_folder.tectonic_vsphere_folder.path}"
  vmware_resource_pool    = "${var.tectonic_vmware_etcd_resource_pool}"
}

data "template_file" "etcd_hostname_list" {
  count    = "${var.tectonic_etcd_count}"
  template = "${var.tectonic_vmware_etcd_hostnames[count.index]}.${var.tectonic_base_domain}"
}

module "ignition_masters" {
  source = "../../modules/ignition"

  base_domain               = "${var.tectonic_base_domain}"
  bootstrap_upgrade_cl      = "${var.tectonic_bootstrap_upgrade_cl}"
  cluster_name              = "${var.tectonic_cluster_name}"
  container_images          = "${var.tectonic_container_images}"
  custom_ca_cert_pem_list   = "${var.tectonic_custom_ca_pem_list}"
  etcd_advertise_name_list  = "${data.template_file.etcd_hostname_list.*.rendered}"
  etcd_ca_cert_pem          = "${module.etcd_certs.etcd_ca_crt_pem}"
  etcd_client_crt_pem       = "${module.etcd_certs.etcd_client_crt_pem}"
  etcd_client_key_pem       = "${module.etcd_certs.etcd_client_key_pem}"
  etcd_count                = "${length(data.template_file.etcd_hostname_list.*.rendered)}"
  etcd_initial_cluster_list = "${data.template_file.etcd_hostname_list.*.rendered}"
  etcd_tls_enabled          = "${var.tectonic_etcd_tls_enabled}"
  etcd_peer_crt_pem         = "${module.etcd_certs.etcd_peer_crt_pem}"
  etcd_peer_key_pem         = "${module.etcd_certs.etcd_peer_key_pem}"
  etcd_server_crt_pem       = "${module.etcd_certs.etcd_server_crt_pem}"
  etcd_server_key_pem       = "${module.etcd_certs.etcd_server_key_pem}"
  image_re                  = "${var.tectonic_image_re}"
  ingress_ca_cert_pem       = "${module.ingress_certs.ca_cert_pem}"
  kube_ca_cert_pem          = "${module.kube_certs.ca_cert_pem}"
  kube_dns_service_ip       = "${module.bootkube.kube_dns_service_ip}"
  kubelet_debug_config      = "${var.tectonic_kubelet_debug_config}"
  kubelet_node_label        = "node-role.kubernetes.io/master"
  kubelet_node_taints       = "node-role.kubernetes.io/master=:NoSchedule"
  use_metadata              = false
}

module "masters" {
  source = "../../modules/vmware/node"

  base_domain                          = "${var.tectonic_base_domain}"
  container_images                     = "${var.tectonic_container_images}"
  core_public_keys                     = ["${var.tectonic_vmware_ssh_authorized_key}"]
  dns_server                           = "${var.tectonic_vmware_node_dns}"
  gateways                             = "${var.tectonic_vmware_master_gateways}"
  hostname                             = "${var.tectonic_vmware_master_hostnames}"
  ign_bootkube_path_unit_id            = "${module.bootkube.systemd_path_unit_id}"
  ign_bootkube_service_id              = "${module.bootkube.systemd_service_id}"
  ign_ca_cert_id_list                  = "${module.ignition_masters.ca_cert_id_list}"
  ign_docker_dropin_id                 = "${module.ignition_masters.docker_dropin_id}"
  ign_installer_kubelet_env_id         = "${module.ignition_masters.installer_kubelet_env_id}"
  ign_installer_runtime_mappings_id    = "${module.ignition_masters.installer_runtime_mappings_id}"
  ign_k8s_node_bootstrap_service_id    = "${module.ignition_masters.k8s_node_bootstrap_service_id}"
  ign_kubelet_service_id               = "${module.ignition_masters.kubelet_service_id}"
  ign_locksmithd_service_id            = "${module.ignition_masters.locksmithd_service_id}"
  ign_max_user_watches_id              = "${module.ignition_masters.max_user_watches_id}"
  ign_tectonic_path_unit_id            = "${module.tectonic.systemd_path_unit_id}"
  ign_tectonic_service_id              = "${module.tectonic.systemd_service_id}"
  ign_update_ca_certificates_dropin_id = "${module.ignition_masters.update_ca_certificates_dropin_id}"
  image_re                             = "${var.tectonic_image_re}"
  instance_count                       = "${var.tectonic_master_count}"
  ip_address                           = "${var.tectonic_vmware_master_ip}"
  kubeconfig                           = "${module.bootkube.kubeconfig}"
  private_key                          = "${var.tectonic_vmware_ssh_private_key_path}"
  vm_disk_datastore                    = "${var.tectonic_vmware_master_datastore}"
  vm_disk_template                     = "${var.tectonic_vmware_vm_template}"
  vm_disk_template_folder              = "${var.tectonic_vmware_vm_template_folder}"
  vm_memory                            = "${var.tectonic_vmware_master_memory}"
  vm_network_labels                    = "${var.tectonic_vmware_master_networks}"
  vm_vcpu                              = "${var.tectonic_vmware_master_vcpu}"
  vmware_clusters                      = "${var.tectonic_vmware_master_clusters}"
  vmware_datacenters                   = "${var.tectonic_vmware_master_datacenters}"
  vmware_folder                        = "${vsphere_folder.tectonic_vsphere_folder.path}"
  vmware_resource_pool                 = "${var.tectonic_vmware_master_resource_pool}"
}

module "ignition_workers" {
  source = "../../modules/ignition"

  bootstrap_upgrade_cl    = "${var.tectonic_bootstrap_upgrade_cl}"
  container_images        = "${var.tectonic_container_images}"
  custom_ca_cert_pem_list = "${var.tectonic_custom_ca_pem_list}"
  etcd_ca_cert_pem        = "${module.etcd_certs.etcd_ca_crt_pem}"
  image_re                = "${var.tectonic_image_re}"
  ingress_ca_cert_pem     = "${module.ingress_certs.ca_cert_pem}"
  kube_ca_cert_pem        = "${module.kube_certs.ca_cert_pem}"
  kube_dns_service_ip     = "${module.bootkube.kube_dns_service_ip}"
  kubelet_debug_config    = "${var.tectonic_kubelet_debug_config}"
  kubelet_node_label      = "node-role.kubernetes.io/node"
  kubelet_node_taints     = ""
}

module "workers" {
  source = "../../modules/vmware/node"

  base_domain                          = "${var.tectonic_base_domain}"
  container_images                     = "${var.tectonic_container_images}"
  core_public_keys                     = ["${var.tectonic_vmware_ssh_authorized_key}"]
  dns_server                           = "${var.tectonic_vmware_node_dns}"
  gateways                             = "${var.tectonic_vmware_worker_gateways}"
  hostname                             = "${var.tectonic_vmware_worker_hostnames}"
  ign_ca_cert_id_list                  = "${module.ignition_workers.ca_cert_id_list}"
  ign_docker_dropin_id                 = "${module.ignition_workers.docker_dropin_id}"
  ign_installer_kubelet_env_id         = "${module.ignition_workers.installer_kubelet_env_id}"
  ign_installer_runtime_mappings_id    = "${module.ignition_workers.installer_runtime_mappings_id}"
  ign_k8s_node_bootstrap_service_id    = "${module.ignition_workers.k8s_node_bootstrap_service_id}"
  ign_kubelet_service_id               = "${module.ignition_workers.kubelet_service_id}"
  ign_locksmithd_service_id            = "${module.ignition_workers.locksmithd_service_id}"
  ign_max_user_watches_id              = "${module.ignition_workers.max_user_watches_id}"
  ign_update_ca_certificates_dropin_id = "${module.ignition_workers.update_ca_certificates_dropin_id}"
  image_re                             = "${var.tectonic_image_re}"
  instance_count                       = "${var.tectonic_worker_count}"
  ip_address                           = "${var.tectonic_vmware_worker_ip}"
  kubeconfig                           = "${module.bootkube.kubeconfig}"
  private_key                          = "${var.tectonic_vmware_ssh_private_key_path}"
  vm_disk_datastore                    = "${var.tectonic_vmware_worker_datastore}"
  vm_disk_template                     = "${var.tectonic_vmware_vm_template}"
  vm_disk_template_folder              = "${var.tectonic_vmware_vm_template_folder}"
  vm_memory                            = "${var.tectonic_vmware_worker_memory}"
  vm_network_labels                    = "${var.tectonic_vmware_worker_networks}"
  vm_vcpu                              = "${var.tectonic_vmware_worker_vcpu}"
  vmware_clusters                      = "${var.tectonic_vmware_worker_clusters}"
  vmware_datacenters                   = "${var.tectonic_vmware_worker_datacenters}"
  vmware_folder                        = "${vsphere_folder.tectonic_vsphere_folder.path}"
  vmware_resource_pool                 = "${var.tectonic_vmware_worker_resource_pool}"
}
