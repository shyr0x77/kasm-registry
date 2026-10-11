#!/usr/bin/env bash
set -Eeuo pipefail

readonly DATASTORE=/tmp/velociraptor-lab
readonly GUI_URL=https://127.0.0.1:8889
readonly ERROR_PAGE=/tmp/kasm-velociraptor-error.html
readonly WAIT_PAGE=/tmp/kasm-velociraptor-wait.html

mkdir -p "$DATASTORE"

cat >"$WAIT_PAGE" <<'EOF'
<!doctype html>
<html lang="fr"><meta charset="utf-8"><meta http-equiv="refresh" content="4;url=https://127.0.0.1:8889"><title>Démarrage de Velociraptor</title>
<style>body{font:20px system-ui;background:#111827;color:#f3f4f6;text-align:center;margin-top:20vh}.mark{color:#ff6b35;font-size:68px}code{color:#86efac}</style>
<div class="mark">◉</div><h1>Velociraptor démarre…</h1><p>Connexion : <code>admin</code> / <code>password</code></p><p>Cette page se recharge automatiquement.</p></html>
EOF

/usr/bin/desktop_ready
google-chrome --new-window --start-maximized "file://$WAIT_PAGE" \
  >/tmp/kasm-velociraptor-chrome.log 2>&1 &

/usr/local/bin/velociraptor gui --nobrowser --datastore "$DATASTORE" &
velociraptor_pid=$!

cleanup() {
  kill "$velociraptor_pid" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

for _ in $(seq 1 120); do
  if curl --insecure --silent --show-error --fail --max-time 2 "$GUI_URL" >/dev/null 2>&1; then
    wait "$velociraptor_pid"
    exit $?
  fi

  if ! kill -0 "$velociraptor_pid" 2>/dev/null; then
    break
  fi
  sleep 2
done

cat >"$ERROR_PAGE" <<'EOF'
<!doctype html>
<html lang="fr"><meta charset="utf-8"><title>Erreur Velociraptor</title>
<style>body{font:18px system-ui;background:#111827;color:#f3f4f6;max-width:850px;margin:10vh auto;padding:32px}code{color:#86efac}h1{color:#fca5a5}</style>
<h1>Velociraptor n'a pas démarré</h1><p>Consultez <code>/tmp/kasm-velociraptor-startup.log</code> dans un terminal du workspace.</p></html>
EOF

google-chrome --new-window --start-maximized "file://$ERROR_PAGE" \
  >/tmp/kasm-velociraptor-chrome-error.log 2>&1 &
wait "$velociraptor_pid" 2>/dev/null || true
exit 1
