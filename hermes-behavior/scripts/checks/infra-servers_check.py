"""infra-servers check — verify server connectivity facts in vault notes."""
import subprocess, socket, re

SERVERS = [
    ("192.168.5.9",  5984, "NAS CouchDB"),
    ("38.244.44.19", 22,   "external-server SSH"),
]

def _tcp_ping(host, port, timeout=5):
    """Check if TCP port is reachable."""
    try:
        s = socket.create_connection((host, port), timeout=timeout)
        s.close()
        return True
    except Exception:
        return False


def check(note_path, fm, content):
    findings = []

    for host, port, name in SERVERS:
        # Only check if the note mentions this server
        if host not in content and name not in content:
            continue

        reachable = _tcp_ping(host, port, timeout=5)

        # Check if note claims opposite state
        up_claim = re.search(rf'{re.escape(name)}.*?(在线|online|reachable|可达)', content, re.IGNORECASE)
        down_claim = re.search(rf'{re.escape(name)}.*?(离线|offline|unreachable|不可达)', content, re.IGNORECASE)

        if up_claim and not reachable:
            findings.append({
                "severity": "stale",
                "claim": f"{name} ({host}:{port}) is online/reachable",
                "actual": f"{host}:{port} is UNREACHABLE",
                "suggestion": f"Check {name} status and update note"
            })
        elif down_claim and reachable:
            findings.append({
                "severity": "stale",
                "claim": f"{name} ({host}:{port}) is offline/unreachable",
                "actual": f"{host}:{port} is now reachable",
                "suggestion": f"Update note: {name} is back online"
            })

    # Check for frp tunnel mentions
    if "frp" in content.lower() and "15984" in content:
        frp_reachable = _tcp_ping("127.0.0.1", 15984, timeout=3)
        # If note says frp tunnel is running but it's not
        if not frp_reachable:
            frp_up = re.search(r'frp.*?(运行|running|active|在线)', content, re.IGNORECASE)
            if frp_up:
                findings.append({
                    "severity": "info",
                    "claim": "frp tunnel is running on 127.0.0.1:15984",
                    "actual": "127.0.0.1:15984 is not listening",
                    "suggestion": "Check frp tunnel status"
                })

    return findings
