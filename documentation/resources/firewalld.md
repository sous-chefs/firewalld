# firewalld

Install the daemon and Ruby D-Bus client used by the object resources.

| Action | Effect |
| --- | --- |
| `:install` (default) | Install the gem/package, reload D-Bus after package changes, enable and start firewalld |
| `:reload` | Reload permanent configuration into runtime |
| `:restart` | Restart the daemon |
| `:disable` | Disable and stop the service |
| `:delete` | Disable/stop the service and remove the package; independently managed object files are retained |

| Property | Type | Default | Purpose |
| --- | --- | --- | --- |
| `dbus_gem_version` | String | `0.25.0` | Ruby D-Bus version |
| `package_options` | String | Unset | Distribution package options |

```ruby
firewalld 'default'
firewalld_zone 'application' do
  ports ['443/tcp']
end
```
