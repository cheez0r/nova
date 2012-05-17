#
# Cookbook Name:: nova
# Recipe:: postgresql
#

Chef::Log.info("PostgreSQL recipe included")

package "python-psycopg2"

bash "postgresql-grant-nova-user-privileges" do
  code <<-EOH
    echo "GRANT ALL ON DATABASE #{node[:nova][:db][:database]} TO #{node[:nova][:db][:user]}" | su - postgres -c psql
  EOH
  action :nothing
end

bash "postgresql-create-nova-user" do
  code <<-EOH
    echo "CREATE USER #{node[:nova][:db][:user]} WITH PASSWORD '#{node[:nova][:db][:password]}'" | su - postgres -c psql
  EOH
  action :nothing
  notifies :run, "bash[postgresql-grant-nova-user-privileges]", :immediately
end

bash "postgresql-create-nova-db" do
  code <<-EOH
    echo "CREATE DATABASE #{node[:nova][:db][:database]}" | su - postgres -c psql
  EOH
  notifies :run, "bash[postgresql-create-nova-user]", :immediately
end

# save data so it can be found by search
unless Chef::Config[:solo]
  Chef::Log.info("Saving node data")
  node.save
end
