---
name: infra-couchdb
description: CouchDB and LiveSync infrastructure — setup, connection info, pitfalls.
triggers:
  - CouchDB
  - couchdb
  - LiveSync
  - livesync
  - "5984"
  - "15984"
  - sync-daemon
  - vault-push
  - obsidian-sync
---

# Infrastructure — CouchDB & LiveSync

## Architecture

```
Mac Obsidian LiveSync ──push──▶ NAS:5984 (CouchDB)
                                    │ frp tunnel
Company Hermes ──HTTPS──▶ couchdb.raxium.cc ──▶ 127.0.0.1:15984
```

## Connections

| Location | URI |
|----------|-----|
| Home (Mac/Hermes) | `http://192.168.5.9:5984` |
| Company | `https://couchdb.raxium.cc` |

## Authentication

Two layers on public endpoint:
1. nginx Basic Auth (`hermes` / `***`)
2. CouchDB admin (`admin` / `***`)

nginx auto-injects CouchDB auth, so clients only need the nginx layer.

## Key Pitfalls

- **@ in password** breaks URL parsing — use `-u` flag instead of inline creds
- **CORS** must be set via API: `PUT /_node/_local/_config/httpd/enable_cors -d '"true"'`
- **Do NOT mount** `/opt/couchdb/etc` in Docker — only data
- **ERL_FLAGS** not needed — CouchDB auto-loads `local.d/`
- Multiple auth failures → account lock → `docker restart` to clear

## Sync Scripts

- `obsidian-sync.py` — Pull vault from CouchDB (company side)
- `vault-push.py` — Push vault to CouchDB (Mac side)
