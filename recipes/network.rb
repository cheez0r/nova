#
# Cookbook Name:: nova
# Recipe:: network
#
# Copyright 2010, Opscode, Inc.
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

include_recipe "nova::common"
nova_package("network")

if node[:nova][:use_ipv6] == "True" then
  package "radvd"
end

execute "sysctl -p" do
  user "root"
  action :nothing
end

template "/etc/sysctl.conf" do
  source "sysctl.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :run, resources(:execute => "sysctl -p"), :immediately
end

if node[:nova][:network_manager] == "nova.network.manager.FlatManager" and node[:nova][:public_network_gateway_ip] then
  execute "ip a add #{node[:nova][:public_network_gateway_ip]} dev #{node[:nova][:public_interface]}" do
    action :run
    not_if "ip a | grep #{node[:nova][:public_network_gateway_ip]} | grep #{node[:nova][:public_interface]}"
  end
end
