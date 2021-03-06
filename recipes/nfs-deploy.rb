#
# Author:: Shane Davis (<shane.davis@linkdigital.com.au>)
# Cookbook Name:: datashades
# Recipe:: nfs-deploy
#
# Creates NFS directories and exports NFS paths
#
# Copyright 2016, Link Digital
#
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

include_recipe "datashades::stackparams"

# Exports need to be defined here so sitename is set correctly
#
node.default['datashades']['nfs']['exports'] = ["/data/nfs/shared_content", "/data/nfs/logs/#{node['datashades']['sitename']}_nginx", "/data/nfs/logs/#{node['datashades']['sitename']}_apache"]

node.default['datashades']['auditd']['rules'].push('/etc/exports')

# Create NFS directories
#
node['datashades']['nfs']['exports'].each do |nfs_path|
	directory nfs_path do
	  owner 'root'
	  group 'ec2-user'
	  mode '0775'
	  action :create
	  recursive true
	end
end

# Create Exports
#
template "/etc/exports" do
	source "nfs-exports.erb"
	mode 00644
end

service "nfs" do
	action [:enable, :restart]
end

execute 'exportfs' do
	command	'exportfs -a'
	user 'root'
	group 'root'
end

if node['datashades']['icinga']['password']
	include_recipe "datashades::icinga-deploy"
end
