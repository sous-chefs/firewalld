# Migrating to the custom resource API

This major release requires Chef/Cinc 18.0 or later. Root recipes, node attributes,
and the legacy `Chef::Resource::Firewall*` / `Chef::Provider::Firewall*` classes
have been removed. Public resource names remain available.

Replace `include_recipe 'firewalld'` with `firewall 'default'`. Replace
`include_recipe 'firewalld::disable_firewall'` with a firewall resource using
`action :disable`. Call the resources from your own wrapper recipe.

## Attributes become properties

| Previous attribute below `node['firewall']` | Replacement on `firewall` |
| --- | --- |
| `allow_ssh`, `allow_winrm`, `allow_mosh`, `allow_loopback`, `allow_icmp` | Properties with the same names; default `false` |
| `allow_established` | `allow_established`, default `true` |
| `ipv6_enabled` | `ipv6_enabled`, default `true` |
| `ubuntu_iptables`, `redhat7_iptables` | `backend :iptables` |
| `firewalld.permanent` | `permanent`, default `false` |
| `iptables.defaults.policy.input` | `input_policy`, default `'DROP'` |
| `iptables.defaults.policy.forward` | `forward_policy`, default `'DROP'` |
| `iptables.defaults.policy.output` | `output_policy`, default `'ACCEPT'` |
| `iptables.defaults.ruleset` | `ruleset` |
| `ufw.defaults` | `ufw_defaults` (complete hash with symbol keys); `ipv6_enabled` controls its IPv6 setting |
| `windows.defaults.policy.input` | `windows_input_policy`, default `'blockinbound'` |
| `windows.defaults.policy.output` | `windows_output_policy`, default `'allowoutbound'` |

Existing `firewall_rule` properties and rule ordering remain available. Rules now
belong only to their `firewall_name`. Ensure the named `firewall` is declared in
the root run context before its rules. One host-wide backend cannot provide
independent rulesets for multiple firewall resources.

Installing `firewall` schedules reconciliation even when no rules remain. On the
iptables and firewalld backends it also supplies the established-connection and
IPv6-ICMP rules formerly supplied by the default recipe. Set `allow_established
false` to opt out. Allow SSH or other management traffic explicitly before
applying a restrictive policy. Native Windows Firewall keeps its built-in default
rules, as before.

## Lifecycle and state

- `firewall :delete` removes Linux backend packages and managed files after
  stopping the firewall. On Windows it resets the managed configuration to OS
  defaults and retains the built-in service.
- `firewall_rule :delete` excludes that rule from the next managed ruleset. Omitting
  a rule has the same effect. `notify_firewall false` suppresses that rule's own
  notification; it remains available to a rebuild scheduled by the parent.
- `nftables :delete` stops the service and removes its package and configuration.
  `nftables_rule :delete` schedules a rebuild without the deleted rule.
- The D-Bus `firewalld :install` now enables and starts the service. Its object
  resources support `:delete`; deletion reloads permanent configuration.
- D-Bus descriptions default to the resource name. Optional fields remain
  unmanaged unless supplied. Explicit `false` is now honoured for zone flags.
- D-Bus tuple-valued ports and normalised rich-rule quoting no longer cause
  repeated updates. Settings added by newer firewalld servers are ignored unless
  the resource exposes a corresponding property.
- Rule state files are written after successful command application. Invalid
  commands do not record a successful desired state. nftables validates its
  configuration before replacing the file.
- Firewalld direct-rule reconciliation now covers IPv4 and IPv6, including rules
  removed from the recipe. It owns the complete direct ruleset. The direct API is
  deprecated upstream; use the D-Bus zone/policy resources for new deployments.
- Structured iptables/firewalld `pre` and `post` rules now use the NAT table.
  iptables disable/delete flush all tables recorded in its managed configuration
  and reset their built-in chain policies to ACCEPT, so redirects and custom
  table policies do not survive removal. Windows status detection accepts padded
  `netsh` output and avoids repeated resets.
- nftables numeric protocols now generate an explicit protocol condition.
  The forwarding chain is correctly named `FORWARD`; address arrays are rendered
  as sets and mixed IPv4/IPv6 sets are rejected.

UFW, iptables and Windows still use their persisted managed rules as the main
change detector. UFW and Windows also recover a disabled firewall; firewalld
compares its live direct rules. External tools should not change managed rules.

## Platforms and distribution

Linux uses systemd; obsolete init-system provider subclasses are removed. Debian
11 test images are retired while Debian remains covered by 12 and 13. Other
platform families remain supported, including Windows.

This repository publishes OCI artifacts only. Do not change dependency resolution
to the unrelated `firewalld` cookbook on Supermarket.
