# firewall

Install and reconcile one host-wide firewall backend. Declare it before its
`firewall_rule` resources. Its name selects the `firewall_name` used by rules;
it does not create an isolated kernel firewall instance.

## Actions

| Action | Effect |
| --- | --- |
| `:install` (default) | Install packages, configure services and schedule a delayed ruleset rebuild |
| `:restart` | Reconcile collected rules; unchanged configuration is a no-op |
| `:disable` | Disable filtering and stop the Linux backend service; retain packages |
| `:flush` | Reset the backend's rules; this is an explicit imperative operation |
| `:save` | Copy firewalld runtime direct rules to permanent configuration; unsupported by other backends |
| `:delete` | Remove Linux backend packages and managed files; Windows resets to OS defaults |

## Properties

| Property | Type | Default | Purpose |
| --- | --- | --- | --- |
| `backend` | Symbol | Platform-dependent | `:ufw`, `:iptables`, `:firewalld` or `:windows` |
| `enabled` / `disabled` | Boolean | `true` / `false` | Skip all actions when disabled |
| `allow_ssh`, `allow_winrm`, `allow_mosh`, `allow_loopback`, `allow_icmp` | Boolean | `false` | Add the corresponding default rule on applicable backends |
| `allow_established` | Boolean | `true` | Add related/established and IPv6 ICMP rules for iptables/firewalld |
| `ipv6_enabled` | Boolean | `true` | Manage IPv6 alongside IPv4 |
| `package_options` | String | Unset | Options passed to the distribution package resource |
| `log_level` | Symbol | `:low` | UFW logging: `low`, `medium`, `high`, `full`, `off` |
| `input_policy`, `forward_policy`, `output_policy` | String | `DROP`, `DROP`, `ACCEPT` | iptables chain policies |
| `ruleset` | Hash | Filter table defaults | Override iptables scaffold as rule text to numeric ordering weight |
| `rules` | Hash | `{}` | Additional backend rule maps, keyed by `iptables`, `ip6tables`, `ufw`, `firewalld` or `windows` |
| `enabled_zone` / `disabled_zone` | Symbol | `:drop` / `:public` | firewalld default zones |
| `permanent` | Boolean | `false` | Also persist firewalld direct rules |
| `ufw_defaults` | Hash | Distribution-compatible defaults | Complete UFW defaults hash with symbol keys: `manage_builtins`, `ipt_sysctl`, `ipt_modules`, `policy` (`input`, `output`, `forward`, `application`); IPv6 comes from `ipv6_enabled` |
| `windows_input_policy` / `windows_output_policy` | String | `blockinbound` / `allowoutbound` | Windows current-profile policy |

`rule_resources` is an internal array used by `firewall_rule` registration and is
excluded from desired-state reporting. Use `firewall_rule` to manage it.

```ruby
firewall 'default' do
  backend :iptables
  allow_ssh true
  allow_loopback true
  input_policy 'DROP'
end

firewall_rule 'HTTPS' do
  port 443
end
```
