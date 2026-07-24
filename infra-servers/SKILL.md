---
name: infra-servers
description: Server inventory and SSH connection information for home infrastructure.
---

# Infrastructure — Servers

## external-server (VPS)

| Item | Detail |
|------|--------|
| OS | Debian 12 |
| IP | 38.244.44.19 |
| Connect | `ssh external-server` |
| Services | nginx, sing-box, frps |

## internal-server (Home Server)

| Item | Detail |
|------|--------|
| OS | AlmaLinux 9.4 |
| IP | 192.168.5.6 |
| Connect | `ssh internal-server` |
| Services | OpenList, frpc, Docker |

## NAS

| Item | Detail |
|------|--------|
| Type | 极空间 |
| IP | 192.168.5.9 |
| Access | Via internal-server only (no direct SSH) |
| Services | CouchDB (Docker), SMB |

## Domains

- `raxium.cc` → Cloudflare → 38.244.44.19
- `openlist.raxium.cc` → File manager
- `couchdb.raxium.cc` → Obsidian sync backend
