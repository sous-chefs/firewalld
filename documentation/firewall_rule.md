# firewall_rule

Declare a rule in a previously declared `firewall`. Rules are ordered by their
numeric `position`, then declaration order. Registration alone does not mark a
resource updated; the backend reports actual changes.

## Actions

- `:create` (default): register the rule and schedule reconciliation.
- `:delete`: schedule reconciliation without this rule.
- `:nothing`: do not register the rule.

## Properties

| Property | Type | Default | Purpose |
| --- | --- | --- | --- |
| `firewall_name` | String | `default` | Owning firewall resource |
| `command` | Symbol | `:allow` | `allow`, `reject`, `deny`, `masquerade`, `redirect`, `log`; backend support varies |
| `protocol` | Symbol or Integer | `:tcp` | IP protocol; use `:none` for an unrestricted protocol |
| `direction` | Symbol | `:in` | `in`, `out`, `pre`, `post`; backend support varies |
| `source`, `destination` | String | Unset | IP address or CIDR |
| `port`, `dest_port`, `source_port` | Integer, Array or Range | Unset | Port selectors; `dest_port` overrides `port` |
| `interface`, `dest_interface` | String | Unset | Input/output interfaces |
| `position` | Integer | `50` | Ordering weight |
| `stateful` | Symbol or Array | Unset | iptables/firewalld connection states; unsupported by UFW |
| `redirect_port` | Integer | Unset | Redirect destination port |
| `logging` | Symbol | Unset | UFW `connections` or `packets` logging |
| `description` | String | Resource name | Rule comment |
| `include_comment` | Boolean | `true` | Include the description in the rule |
| `permanent` | Boolean | `false` | Persist this firewalld direct rule |
| `program`, `service` | String | Unset | Windows executable/service constraint |
| `raw` | String | Unset | Backend-specific raw rule; replaces structured rendering where supported |
| `notify_firewall` | Boolean | `true` | Schedule a parent rebuild; a different notification can still apply a registered rule |

```ruby
firewall 'default' do
  backend :ufw
  allow_ssh true
end

firewall_rule 'HTTPS from application network' do
  source '192.0.2.0/24'
  port 443
  protocol :tcp
  command :allow
end
```
