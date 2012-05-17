#
# Cookbook Name:: nova
# Attributes:: default
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

::Chef::Node.send(:include, Opscode::OpenSSL::Password)

default[:nova][:hostname] = hostname
default[:nova][:install_type] = "binary"
default[:nova][:compute_connection_type] = "qemu"
default[:nova][:my_ip] = ipaddress
default[:nova][:iscsi_ip_prefix] = ipaddress.split('.')[0..2].join('.')
default[:nova][:public_interface] = "eth1"
default[:nova][:vlan_interface] = "eth1"
default[:nova][:mysql] = true
default[:nova][:postgresql] = false
default[:nova][:images] = []
default[:nova][:network] = "10.0.0.0/24 8 32"
default[:nova][:floating_range] = "10.128.0.0/24"
default[:nova][:user] = "admin"
default[:nova][:project] = "admin"
set_unless[:nova][:access_key] = secure_password
set_unless[:nova][:secret_key] = secure_password
default[:nova][:default_project] = "admin"
default[:nova][:network_manager] = "nova.network.manager.VlanManager"
default[:nova][:flat_network_dhcp_start] = "10.0.0.2"
default[:nova][:image_service] = "nova.image.glance.GlanceImageService"
default[:nova][:glance_api_servers] = "localhost:9292"
default[:nova][:lock_path] = "/var/lib/nova/tmp"
default[:nova][:dhcpbridge_flagfile] = "/etc/nova/nova.conf"
default[:nova][:dhcpbridge] = "/usr/bin/nova-dhcpbridge"
default[:nova][:logdir] = "/var/log/nova"
default[:nova][:state_path] = "/var/lib/nova"
default[:nova][:verbose] = true
default[:nova][:auth_strategy] = "noauth"

# Firewall driver for xenapi
if node[:nova] and node[:nova][:connection_type]  and node[:nova][:connection_type] == "xenapi"
  default[:nova][:firewall_driver] = 'nova.virt.xenapi.firewall.Dom0IptablesFirewallDriver'
end

#keystone settings
default[:nova][:keystone_service_protocol] = "http"
default[:nova][:keystone_service_host] = "127.0.0.1"
default[:nova][:keystone_service_port] = "5000"
default[:nova][:keystone_auth_host] = "127.0.0.1"
default[:nova][:keystone_auth_port] = "35357"
default[:nova][:keystone_auth_protocol] = "http"
default[:nova][:keystone_auth_uri] = "http://127.0.0.1:5000/"
default[:nova][:keystone_admin_token] = "999888777666"
