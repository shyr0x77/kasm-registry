#!/usr/bin/env bash
set -Eeuo pipefail

readonly DATASTORE=/tmp/velociraptor-lab
readonly GUI_URL=https://127.0.0.1:8889

mkdir -p "$DATASTORE"

/usr/bin/desktop_ready
/usr/local/bin/velociraptor gui --nobrowser --datastore "$DATASTORE" &
velociraptor_pid=$!

cleanup() {
  kill "$velociraptor_pid" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

for _ in $(seq 1 120); do
  if curl --insecure --silent --show-error --fail --max-time 2 "$GUI_URL" >/dev/null 2>&1; then
    google-chrome --new-window --start-maximized "$GUI_URL" \
      >/tmp/kasm-velociraptor-chrome.log 2>&1 &
    wait "$velociraptor_pid"
    exit $?
  fi

  if ! kill -0 "$velociraptor_pid" 2>/dev/null; then
    break
  fi
  sleep 2
done
wait "$velociraptor_pid" 2>/dev/null || true
exit 1
