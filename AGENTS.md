# Agent Notes

## Platform Matrix

Keep the Linux integration matrix on current, generally available platform releases.
The CI workflow uses `kitchen.dokken.yml` on `ubuntu-latest`; do not add Linux
integration jobs that require Vagrant or macOS-hosted virtualization.

Current Linux targets:

- AlmaLinux 8 and 9 for RHEL-family iptables coverage.
- Amazon Linux 2023 for Amazon firewalld and iptables coverage.
- CentOS Stream 9 for current CentOS Stream iptables coverage.
- Debian 11, 12, and 13 for UFW, nftables, and firewalld D-Bus resource coverage.
- Fedora latest for firewalld D-Bus resource coverage.
- Ubuntu 22.04 and 24.04 for UFW coverage.

Legacy targets intentionally removed from Kitchen and CI because they are EOL:
Amazon Linux 2, CentOS 7, CentOS Stream 8, Debian 9, Debian 10, Fedora 34,
Ubuntu 18.04, and Ubuntu 20.04. FreeBSD, openSUSE, and Oracle Linux entries were
also removed from the active Kitchen matrix because `metadata.rb` does not
declare those platforms as supported by this cookbook.

Windows coverage belongs in `kitchen.windows.yml`; keep it separate from the
Dokken Linux matrix.
