# Firewalld cookbook migration

* Full custom resource migration authorised on 2026-11-12. Retain UFW, iptables,
  Windows Firewall, nftables and firewalld D-Bus capabilities. Remove root recipes,
  attributes and the legacy Chef resource/provider class hierarchy.
* This is the distinct `sous-chefs/firewalld` extraction, not `sous-chefs/firewall`.
  Publish OCI only. Keep `supermarket_publisher: none`; never publish to Supermarket.
* Implement against main at its existing released version. Use a breaking feature
  commit so Release Please incorporates the migration into the major release.
* Replace implicit backend attributes with an explicit `backend` property. Preserve
  current default routing: Debian family uses UFW, Amazon uses firewalld, RHEL/Fedora
  use iptables, Windows uses its native firewall. nftables remains explicit.
* Keep the existing rule renderers and ordering semantics. Collect only rules for
  the named firewall, and schedule reconciliation without reporting rule registration
  as a system update. Package/service/file changes determine update status.
* Linux packages come from distribution repositories; no source build or custom
  repository is required. Kernel firewall support and NET_ADMIN are required.
  Dokken tests must use isolated privileged containers, never host networking.
* Preserve Linux platform families and Windows. Retire Debian 11 CI images in favour
  of Debian 12/13; retain Ubuntu 22.04/24.04, AlmaLinux 8/9, Amazon 2023,
  CentOS Stream 9 and Fedora. Windows execution requires a Windows runner.
* Windows Firewall is included in supported Windows releases. Linux firewall
  packages are architecture-dependent distro builds; verify arm64 locally and
  amd64 in CI without treating one architecture's success as proof of the other.
* Do not test firewall disable/flush operations on the host or a production machine.

## Sources

* https://firewalld.org/documentation/
* https://ubuntu.com/server/docs/how-to/security/firewalls/
* https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/

Linux CI uses Dokken on ubuntu-latest; do not add Vagrant or macOS VM jobs.
Windows coverage stays in kitchen.windows.yml. Previously retired unsupported
platforms (FreeBSD, openSUSE and Oracle Linux) must not be reintroduced without
a corresponding supported-platform decision.
