# firewall_backend_ufw

Internal backend used by [`firewall`](firewall.md). It shares the firewall
properties and lifecycle actions; configure it through `firewall` with
`backend :ufw` so rule registration and delayed reconciliation are applied.
