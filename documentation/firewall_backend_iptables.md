# firewall_backend_iptables

Internal backend used by [`firewall`](firewall.md). It shares the firewall
properties and lifecycle actions; configure it through `firewall` with
`backend :iptables` so rule registration and delayed reconciliation are applied.
