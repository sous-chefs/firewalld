# frozen_string_literal: true

name 'firewalld'
run_list 'test::default'
cookbook 'firewalld', path: '.'
cookbook 'test', path: './test/cookbooks/test'

%w(default firewalld ufw iptables windows).each do |suite|
  named_run_list suite.to_sym, 'test::default'
end
named_run_list :nftables, 'test::nftables'
named_run_list :firewalld_dbus, 'test::firewalld_dbus'

named_run_list :delete, 'test::delete'
named_run_list :dbus_delete, 'test::dbus_delete'
named_run_list :nftables_delete, 'test::nftables_delete'
