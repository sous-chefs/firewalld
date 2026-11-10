# frozen_string_literal: true

name 'firewalld'

run_list 'firewalld::default', 'firewall-test::default'

cookbook 'apt', git: 'https://github.com/sous-chefs/apt.git', branch: 'main'
cookbook 'firewalld', path: '.'
cookbook 'firewall-test', path: './test/fixtures/cookbooks/firewall-test'
cookbook 'firewalld-test', path: './test/fixtures/cookbooks/firewalld-test'
cookbook 'nftables-test', path: './test/fixtures/cookbooks/nftables-test'

named_run_list :default, 'firewalld::default', 'firewall-test::default'
named_run_list :firewalld, 'firewalld::default', 'firewall-test::default'
named_run_list :ufw, 'firewalld::default', 'firewall-test::default'
named_run_list :iptables, 'firewalld::default', 'firewall-test::default'
named_run_list :nftables, 'nftables-test::default'
named_run_list :firewalld_dbus, 'firewalld-test::default'
named_run_list :windows, 'firewalld::default', 'firewall-test::default'
