# firewalld cookbook

Manage Linux and Windows firewalls with Chef custom resources. This is the
`sous-chefs/firewalld` extraction of the `firewall` cookbook. Obtain it from this
repository or its OCI artifact in GHCR. It is unrelated to the cookbook with the
same name on Chef Supermarket and is **never published to Supermarket**. Do not
load this cookbook and `firewall` in the same Chef run: their resource names overlap.

## Requirements

- Chef Infra Client or Cinc 18.0 or later.
- Linux with systemd and the kernel modules required by the selected firewall, or
  Windows with Windows Defender Firewall.
- Root or administrator access to configure the host firewall.

Linux packages come from the distribution repositories. Supported platform
families are Debian/Ubuntu, AlmaLinux/CentOS, Amazon Linux, and Fedora. The test
matrix covers Debian 12/13, Ubuntu 22.04/24.04, AlmaLinux 8/9, CentOS Stream 9,
Amazon Linux 2023 and Fedora latest. Windows runs in a separate native runner.

## Usage

Add `depends 'firewalld'` to your wrapper cookbook and declare resources:

```ruby
firewall 'default' do
  backend :ufw
  allow_ssh true
end

firewall_rule 'HTTPS' do
  port 443
  protocol :tcp
end
```

The default backend is UFW on Debian/Ubuntu, firewalld on Amazon Linux, iptables
on AlmaLinux/CentOS/Fedora, and Windows Firewall on Windows. Select a different
backend explicitly with `backend`. Use `nftables` and `nftables_rule` for nftables.

The generic `firewall` resource owns the selected backend's host-wide managed
ruleset. Declare one firewall resource per host/backend and keep its rules in the
same Chef run. Omitted rules are removed at the delayed rebuild. Declaring a rule
alone does not report a system change. Explicit `:restart` reconciles the rules;
`:flush`, `:disable` and `:delete` have different effects described in the resource
documentation. Do not combine independent firewall managers on the same host.

For firewalld's permanent zones, services, policies, helpers, ICMP types and
IP sets, use the D-Bus resources instead:

```ruby
firewalld 'default'

firewalld_zone 'application' do
  services ['ssh']
  ports ['443/tcp']
  forward false
end

firewalld_config 'default zone' do
  default_zone 'application'
end
```

`firewalld :install` installs the D-Bus gem and package, enables the service and
starts it. Object resources update permanent configuration and reload firewalld
when something changes. Unspecified optional properties are left alone; explicit
`false` and empty arrays are applied. Use `action :delete` to remove an object.

## Resources

- [firewall](documentation/firewall.md)
- [firewall_rule](documentation/firewall_rule.md)
- [nftables](documentation/resource_nftables.md) and [nftables_rule](documentation/resource_nftables_rule.md)
- [firewalld](documentation/resources/firewalld.md)
- [firewalld_config](documentation/resources/firewalld_config.md)
- [firewalld_helper](documentation/resources/firewalld_helpers.md)
- [firewalld_icmptype](documentation/resources/firewalld_icmptype.md)
- [firewalld_ipset](documentation/resources/firewalld_ipset.md)
- [firewalld_policy](documentation/resources/firewalld_policy.md)
- [firewalld_service](documentation/resources/firewalld_service.md)
- [firewalld_zone](documentation/resources/firewalld_zone.md)

See [MIGRATING.md](MIGRATING.md) before upgrading from the recipe/attribute API.

## Testing

```sh
chef install
chef exec cookstyle --cache false
chef exec rspec
KITCHEN_LOCAL_YAML=kitchen.dokken.yml kitchen test default-ubuntu-2404
```

Kitchen runs each recipe twice and enforces a zero-change second converge.
Dokken uses isolated privileged containers; never use host networking for these
tests. The D-Bus fixture configures its zone services explicitly because Docker
kernels may omit the NetBIOS conntrack helper used by distribution defaults.

For lifecycle testing, retain an instance with `kitchen test INSTANCE
--destroy=never`, then run `FIREWALL_TEST_RUN_LIST=delete kitchen converge INSTANCE`
with the same Kitchen configuration. Use `dbus_delete` for the D-Bus suite and
`nftables_delete` for nftables. These recipes remove the fixture's configuration;
run them only in disposable test instances. Verify removal with the same
`FIREWALL_TEST_RUN_LIST` and `kitchen verify INSTANCE --test-base-path test/lifecycle`
to select only the removal profile. When testing an explicit iptables backend
on Amazon Linux, also set `FIREWALL_TEST_BACKEND=iptables`.

## Maintainers

Maintained by [Sous Chefs](https://sous-chefs.org/). Contributions are welcome.
Licensed under Apache-2.0; see [LICENSE](LICENSE).
