# frozen_string_literal: true
require 'ipaddr'
provides :firewall_rule
unified_mode true
default_action :create
property(:firewall_name, kind_of: String, default: 'default')

property(:command, kind_of: Symbol, equal_to: [:reject, :allow, :deny, :masquerade, :redirect, :log], default: :allow)

property(:protocol, kind_of: [Integer, Symbol], default: :tcp,
                    callbacks: { 'must be either :tcp, :udp, :icmp, :\'ipv6-icmp\', :icmpv6, :none, or a valid IP protocol number' => lambda do |p|
                      !!(p.to_s =~ /(udp|tcp|icmp|icmpv6|ipv6-icmp|esp|ah|ipv6|none)/ || (p.to_s =~ /^\d+$/ && p.between?(0, 142)))
                    end })
property(:direction, kind_of: Symbol, equal_to: [:in, :out, :pre, :post], default: :in)
property(:logging, kind_of: Symbol, equal_to: [:connections, :packets])

property(:source, kind_of: String, callbacks: { 'must be a valid ip address' => ->(ip) { !!IPAddr.new(ip) } })
property(:source_port, kind_of: [Integer, Array, Range]) # source port
property(:interface, kind_of: String)

property(:port, kind_of: [Integer, Array, Range]) # shorthand for dest_port
property(:destination, kind_of: String, callbacks: { 'must be a valid ip address' => ->(ip) { !!IPAddr.new(ip) } })
property(:dest_port, kind_of: [Integer, Array, Range])
property(:dest_interface, kind_of: String)

property(:position, kind_of: Integer, default: 50)
property(:stateful, kind_of: [Symbol, Array])
property(:redirect_port, kind_of: Integer)
property(:description, kind_of: String, name_property: true)
property(:include_comment, kind_of: [TrueClass, FalseClass], default: true)

# only used for firewalld
property(:permanent, kind_of: [TrueClass, FalseClass], default: false)

# only used for Windows Firewalls
property(:program, kind_of: String)
property(:service, kind_of: String)

# for when you just want to pass a raw rule
property(:raw, kind_of: String)

# do you want this rule to notify the firewall to recalculate
# (and potentially reapply) the firewall_rule(s) it finds?
property(:notify_firewall, kind_of: [TrueClass, FalseClass], default: true)

action :create do
  rule = new_resource
  with_run_context :root do
    edit_resource!(:firewall, rule.firewall_name) do
      rule_resources(rule_resources + [rule])
      delayed_action :restart if rule.notify_firewall
    end
  end
end

action :delete do
  next unless new_resource.notify_firewall
  with_run_context :root do
    edit_resource!(:firewall, new_resource.firewall_name) do
      delayed_action :restart
    end
  end
end
