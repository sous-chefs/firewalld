# frozen_string_literal: true

provides :firewall_backend_firewalld
unified_mode true
use '_partial/_firewall'

action :install do
  package 'firewalld' do
    options new_resource.package_options if new_resource.package_options
  end
  file firewalld_rules_filename do
    content '# created by chef to allow service to start'
    action :create_if_missing
  end
  systemd_unit 'firewalld.service' do
    action %i(enable start)
  end
end

action :restart do
  desired = (new_resource.rules['firewalld'] || {}).dup
  new_resource.rule_resources.each do |rule|
    ip_versions(rule).each do |family|
      next if family == 'ipv6' && !new_resource.ipv6_enabled
      args = build_firewall_rule(rule, family)
      desired["firewall-cmd --direct --add-rule #{args}"] = rule.position
      desired["firewall-cmd --permanent --direct --add-rule #{args}"] = rule.position if rule.permanent || new_resource.permanent
    end
  end
  systemd_unit 'firewalld.service' do
    action %i(enable start)
  end
  execute "set #{new_resource.name} firewalld zone" do
    command ['firewall-cmd', "--set-default-zone=#{new_resource.enabled_zone}"]
    not_if { firewalld_default_zone?(new_resource.enabled_zone) }
  end
  contents = build_rule_file(desired)
  ruby_block "apply #{new_resource.name} firewalld rules" do
    block do
      firewalld_flush!
      desired.sort_by { |_rule, position| position }.each { |rule, _position| firewalld_rule!(rule) }
    end
    only_if { !::File.exist?(firewalld_rules_filename) || ::File.read(firewalld_rules_filename) != contents || !direct_rules_match?(desired.keys) }
  end
  file firewalld_rules_filename do
    content contents
    mode '0600'
  end
end

%i(flush disable delete).each do |operation|
  action operation do
    ruby_block "#{operation} #{new_resource.name} firewalld" do
      block do
        firewalld_flush!
        firewalld_default_zone!(new_resource.disabled_zone) if operation != :flush
      end
      only_if { ::File.exist?('/usr/bin/firewall-cmd') && firewalld_active? }
    end
    file firewalld_rules_filename do
      content '# created by chef to allow service to start'
      action(operation == :delete ? :delete : :create)
    end
    if operation != :flush
      systemd_unit 'firewalld.service' do
        action %i(disable stop)
      end
    end
    if operation == :delete
      package 'firewalld' do
        action :remove
      end
    end
  end
end

action :save do
  ruby_block "save #{new_resource.name} firewalld rules" do
    block { firewalld_save! }
    not_if { firewalld_all_rules_permanent! }
  end
end

action_class do
  include FirewallCookbook::Helpers::Firewalld
end
