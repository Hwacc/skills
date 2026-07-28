"""infra-couchdb check — verify CouchDB facts in vault notes."""
import subprocess, json, re

COUCH_URL = "https://couchdb.raxium.cc"
COUCH_USER = "hermes"
COUCH_PASS = "fnidvEVK6GbVrI/A1faIdg=="


def _curl(path):
    """Call CouchDB API, skip SSL verify."""
    r = subprocess.run(
        ["curl", "-sk", "--max-time", "10", "-u", f"{COUCH_USER}:{COUCH_PASS}",
         f"{COUCH_URL}{path}"],
        capture_output=True, text=True, timeout=15
    )
    if r.returncode != 0:
        return None
    try:
        return json.loads(r.stdout)
    except json.JSONDecodeError:
        return None


def check(note_path, fm, content):
    findings = []

    # 1. Check if CouchDB is online
    up = _curl("/_up")
    if up is None:
        findings.append({
            "severity": "stale",
            "claim": "CouchDB is online",
            "actual": "UNREACHABLE",
            "suggestion": "Check CouchDB status and frp tunnel"
        })
        return findings

    # 2. Check doc_count
    db = _curl("/obsidian")
    if db:
        actual_count = db.get("doc_count", "?")
        # Look for doc_count claims in the note content
        match = re.search(r'(\d+)\s*(?:个|篇)?\s*(?:文档|note|doc)', content)
        if match:
            claimed = int(match.group(1))
            if claimed != actual_count:
                findings.append({
                    "severity": "stale",
                    "claim": f"obsidian DB has {claimed} documents",
                    "actual": f"obsidian DB has {actual_count} documents",
                    "suggestion": "Update doc_count in note"
                })

    # 3. Check disk_size
    if db and "sizes" in db:
        sizes = db["sizes"]
        disk_mb = sizes.get("file", 0) / (1024 * 1024)
        match = re.search(r'(\d+\.?\d*)\s*(?:MB|mb)', content)
        if match:
            claimed_mb = float(match.group(1))
            if abs(claimed_mb - disk_mb) > 0.5:
                findings.append({
                    "severity": "stale",
                    "claim": f"disk size ~{claimed_mb:.1f} MB",
                    "actual": f"disk size ~{disk_mb:.1f} MB",
                    "suggestion": "Update disk_size in note"
                })

    # 4. Check databases
    dbs = _curl("/_all_dbs")
    if dbs:
        db_list = ", ".join(dbs) if dbs else "(empty)"
        # If note mentions specific DB names that don't exist
        for db_name in ["obsidian", "obsidian-personal", "obsidian-work"]:
            if db_name in content and db_name not in dbs:
                findings.append({
                    "severity": "stale",
                    "claim": f"database '{db_name}' exists",
                    "actual": f"databases: {db_list}",
                    "suggestion": f"Database '{db_name}' not found — update or remove reference"
                })

    return findings
