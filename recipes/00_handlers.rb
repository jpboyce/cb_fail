#
# Cookbook:: cb_fail
# Recipe:: 00_handlers
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# include the chef handler recipe
include_recipe "chef_handler::default"

# Create handler directory because it doesnt exist by default and will cause things to error out
directory "#{node['chef_handler']['handler_path']}" do
  recursive true
  action :create
end

# Create handler file on node
cookbook_file "#{node['chef_handler']['handler_path']}/errors-to-slack.rb" do
  source 'errors-to-slack.rb'
  action :create
end

# Handlier resource
chef_handler 'ErrorsToSlackModule::ErrorsToSlack' do
  source "#{node['chef_handler']['handler_path']}/errors-to-slack.rb"
  supports start: false, report: false, exception: true
  action :enable
end

# Fail on purpose
ruby_block 'fail the run' do
  block do
    fail 'deliberately fail the run'
  end
end
