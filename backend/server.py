"""
Simple control endpoint + web UI for MAL/RULS data exchange.
Run with:  python backend/server.py
Dependencies: flask (pip install flask)
"""
from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any, Dict, List

from flask import Flask, jsonify, request

app = Flask(__name__)

BASE_DIR = Path(__file__).parent
DATA_DIR = BASE_DIR / "data"
DB_FILE = DATA_DIR / "db.json"

URI_RESERVED = {
    "|": "|22",
    " ": "|20",
    "!": "|21",
    "#": "|23",
    "$": "|24",
    "%": "|25",
    "&": "|26",
    '"': "|5e",
    "'": "|27",
    "(": "|28",
    ")": "|29",
    "*": "|2a",
    "+": "|2b",
    ",": "|2c",
    "/": "|2f",
    ":": "|3a",
    ";": "|3b",
    "=": "|3d",
    "?": "|3f",
    "@": "|41",
    "[": "|5b",
    "]": "|5d",
    "\\": "|5f",
}
URI_REVERSE = {v: k for k, v in URI_RESERVED.items()}

DEFAULT_DB: Dict[str, Any] = {
    "mal": {"last_status": None, "updated_at": None},
    "ruls": {"last_status": None, "updated_at": None},
    "moderation": {"reports": [], "warnings": {}, "tempbans": [], "permabans": {}, "roles": {}},
    "command_queue": {"MAL": [], "RULS": []},
}

API_PASSWORD = os.environ.get("API_PASSWORD", "changeme")


def ensure_storage() -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    if not DB_FILE.exists():
        DB_FILE.write_text(json.dumps(DEFAULT_DB, indent=2))


def load_db() -> Dict[str, Any]:
    ensure_storage()
    try:
        return json.loads(DB_FILE.read_text())
    except Exception:
        return json.loads(json.dumps(DEFAULT_DB))


def save_db(db: Dict[str, Any]) -> None:
    ensure_storage()
    DB_FILE.write_text(json.dumps(db, indent=2))


def decode_payload(raw: str) -> Dict[str, Any]:
    for key, value in URI_REVERSE.items():
        raw = raw.replace(key, value)
    return json.loads(raw)


def is_authorized(req) -> bool:
    supplied = req.args.get("password") or req.headers.get("X-Api-Key")
    return bool(API_PASSWORD) and supplied == API_PASSWORD


def enqueue_command(db: Dict[str, Any], target: str, command: Dict[str, Any]) -> None:
    queue = db.setdefault("command_queue", {}).setdefault(target, [])
    queue.append(command)


def pop_commands(db: Dict[str, Any], target: str) -> List[Dict[str, Any]]:
    queue = db.setdefault("command_queue", {}).setdefault(target, [])
    cmds = list(queue)
    queue.clear()
    return cmds


def upsert_moderation(db: Dict[str, Any], moderation: Dict[str, Any]) -> None:
    for key in ("reports", "warnings", "tempbans", "permabans", "roles"):
        if key in moderation:
            db.setdefault("moderation", {})[key] = moderation[key]


@app.get("/api/health")
def health():
    return {"status": "ok"}


@app.get("/api/state")
def get_state():
    return jsonify(load_db())


@app.get("/api/mal")
def ingest_mal():
    if not is_authorized(request):
        return {"error": "unauthorized"}, 401
    db = load_db()
    raw = request.args.get("data", "")
    if raw:
        try:
            packet = decode_payload(raw)
            db["mal"]["last_status"] = packet.get("payload")
            db["mal"]["updated_at"] = packet.get("timestamp")
            save_db(db)
        except Exception as exc:  # noqa: BLE001
            return jsonify({"error": str(exc)}), 400
    commands = pop_commands(db, "MAL")
    save_db(db)
    return jsonify({"target": "MAL", "commands": commands})


@app.get("/api/ruls")
def ingest_ruls():
    if not is_authorized(request):
        return {"error": "unauthorized"}, 401
    db = load_db()
    raw = request.args.get("data", "")
    if raw:
        try:
            packet = decode_payload(raw)
            payload = packet.get("payload", {})
            db["ruls"]["last_status"] = payload
            db["ruls"]["updated_at"] = packet.get("timestamp")
            if "moderation" in payload:
                upsert_moderation(db, payload["moderation"])
            save_db(db)
        except Exception as exc:  # noqa: BLE001
            return jsonify({"error": str(exc)}), 400
    commands = pop_commands(db, "RULS")
    save_db(db)
    return jsonify({"target": "RULS", "commands": commands})


@app.post("/api/commands/mal")
def add_mal_command():
    if not is_authorized(request):
        return {"error": "unauthorized"}, 401
    db = load_db()
    data = request.get_json(force=True)
    if not data:
        return {"error": "missing body"}, 400
    if isinstance(data, dict) and "commands" in data:
        for cmd in data["commands"]:
            enqueue_command(db, "MAL", cmd)
    else:
        enqueue_command(db, "MAL", data)
    save_db(db)
    return {"queued": True}


@app.post("/api/commands/ruls")
def add_ruls_command():
    if not is_authorized(request):
        return {"error": "unauthorized"}, 401
    db = load_db()
    data = request.get_json(force=True)
    if not data:
        return {"error": "missing body"}, 400
    if isinstance(data, dict) and "commands" in data:
        for cmd in data["commands"]:
            enqueue_command(db, "RULS", cmd)
    else:
        enqueue_command(db, "RULS", data)
    save_db(db)
    return {"queued": True}


@app.get("/")
def ui():
    db = load_db()
    html = f"""
    <!doctype html>
    <html lang='en'>
    <head>
        <meta charset='utf-8' />
        <title>MAL/RULS Control</title>
        <style>
            :root {{ font-family: "Segoe UI", sans-serif; background:#0f172a; color:#e2e8f0; }}
            body {{ max-width:1200px; margin:24px auto; padding:0 16px; }}
            h1 {{ letter-spacing:0.02em; }}
            section {{ margin-bottom:24px; padding:16px; border-radius:12px; background:#111827; box-shadow:0 10px 40px rgba(0,0,0,0.25); }}
            pre {{ background:#0b1220; padding:12px; border-radius:8px; overflow:auto; }}
            label {{ display:block; margin:8px 0 4px; font-weight:600; }}
            input, textarea {{ width:100%; padding:8px; border-radius:8px; border:1px solid #1f2937; background:#0b1220; color:#e2e8f0; }}
            button {{ margin-top:8px; padding:10px 14px; border:none; border-radius:8px; background:#10b981; color:#0b1220; font-weight:700; cursor:pointer; }}
            button:hover {{ background:#34d399; }}
            .grid {{ display:grid; grid-template-columns:repeat(auto-fit,minmax(300px,1fr)); gap:16px; }}
        </style>
    </head>
    <body>
        <h1>MAL / RULS Control Panel</h1>
        <section>
            <div class="grid">
                <div>
                    <h2>MAL Latest</h2>
                    <pre>{json.dumps(db.get('mal',{}), indent=2)}</pre>
                </div>
                <div>
                    <h2>RULS Latest</h2>
                    <pre>{json.dumps(db.get('ruls',{}), indent=2)}</pre>
                </div>
                <div>
                    <h2>Moderation</h2>
                    <pre>{json.dumps(db.get('moderation',{}), indent=2)}</pre>
                </div>
            </div>
        </section>
        <section>
            <h2>Queue Command</h2>
            <form id="cmd-form">
                <label>Target (MAL or RULS)</label>
                <input name="target" value="MAL" />
                <label>Command JSON</label>
                <textarea name="command" rows="6">{{"action":"announce","message":"Hello from UI"}}</textarea>
                <button type="submit">Queue</button>
            </form>
            <div id="cmd-result"></div>
        </section>
        <script>
            document.getElementById('cmd-form').addEventListener('submit', async (ev) => {{
                ev.preventDefault();
                const target = ev.target.target.value.trim();
                const cmdRaw = ev.target.command.value;
                let payload;
                try {{ payload = JSON.parse(cmdRaw); }} catch (err) {{ alert('Invalid JSON'); return; }}
                const endpoint = target.toUpperCase() === 'RULS' ? '/api/commands/ruls' : '/api/commands/mal';
                const res = await fetch(endpoint, {{ method:'POST', headers:{{'Content-Type':'application/json'}}, body: JSON.stringify(payload) }});
                const text = await res.text();
                document.getElementById('cmd-result').innerText = text;
            }});
        </script>
    </body>
    </html>
    """
    return html


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "12500"))
    app.run(host="0.0.0.0", port=port, debug=True)
