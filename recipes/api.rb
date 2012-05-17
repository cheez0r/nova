#
# Cookbook Name:: nova
# Recipe:: api
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

# Locate glance api servers
unless Chef::Config[:solo]
  api_nodes = search(:node, "recipes:glance\\:\\:api")
  glance_api_servers = []

  api_nodes.each do |api_node|
    ip = api_node[:glance][:my_ip]
    port = api_node[:glance][:api_bind_port]
    glance_api_servers.push("#{ip}:#{port}")
  end

  Chef::Log.info("Found #{glance_api_servers.count} Glance API server(s)")

  if not glance_api_servers.empty?
    node.default[:nova][:glance_api_servers] = glance_api_servers.join(",")
  end
end

if node[:nova][:auth_strategy] and node[:nova][:auth_strategy] == "keystone" then
  package "python-keystone"
end

nova_package("api")

template "/etc/nova/api-paste.ini" do
  source "api-paste.ini.erb"
  owner "nova"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "nova-api")
end
