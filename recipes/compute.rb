# NOTE: I manually reimplented the nova-compute startup here so that it
# works on stock cloud servers. This works around the fact that stock
# Ubuntu Cloud Servers images don't have the 'nbd' (network block device)
# kernel module.

include_recipe "nova::common"

package_version = node['nova']["compute_version"]

package "nova-compute" do
  options "--force-yes"
  action :install
  version package_version if package_version
end

if node[:nova][:connection_type] and node[:nova][:connection_type] == "xenapi" then

  # FIXME: create a python XenAPI package
  package "python-pip"
  execute "/usr/bin/pip install xenapi" do
    not_if "python -c 'import XenAPI'"
  end

elsif node[:nova][:connection_type] and node[:nova][:connection_type] == "kvm" then

  service "libvirt-bin" do
    notifies :restart, resources(:service => "nova-compute"), :immediately
  end

  execute "modprobe kvm" do
    action :run
    notifies :restart, resources(:service => "libvirt-bin"), :immediately
  end

  execute "modprobe nbd" do
    action :run
  end
# default
elsif not node[:nova][:connection_type] or node[:nova][:connection_type] == "libvirt" then

  directory "/dev/cgroup" do
    owner "root"
    group "root"
    mode "0755"
    action :create
  end

  execute "mount -t cgroup none /dev/cgroup -o devices" do
    not_if "mount | grep cgroup"
  end

  service "libvirt-bin"

  cookbook_file "/etc/libvirt/qemu.conf" do
    source "qemu.conf"
    mode "0644"
    notifies :restart, resources(:service => "libvirt-bin")
  end

end

service "nova-compute" do
  if (platform?("ubuntu") && node.platform_version.to_f >= 10.04)
    restart_command "stop nova-compute; start nova-compute"
    stop_command "stop nova-compute"
    start_command "start nova-compute"
    status_command "status nova-compute | cut -d' ' -f2 | cut -d'/' -f1 | grep start"
  end
  supports :status => true, :restart => true
  action :start
  subscribes :restart, resources(:template => ["/etc/nova/nova.conf"])
end
