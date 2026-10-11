#!/usr/bin/env bash
set -Eeuo pipefail

readonly N8N_URL=http://127.0.0.1:5678
readonly N8N_DATA_DIR=/home/kasm-user/.n8n

mkdir -p "${N8N_DATA_DIR}"
chmod 0700 "${N8N_DATA_DIR}"

export HOME=/home/kasm-user
export N8N_LISTEN_ADDRESS=127.0.0.1
export N8N_PORT=5678
export N8N_PROTOCOL=http
export N8N_SECURE_COOKIE=false
export N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
export N8N_DIAGNOSTICS_ENABLED=false
export N8N_PERSONALIZATION_ENABLED=false
export N8N_BLOCK_ENV_ACCESS_IN_NODE=true
export GENERIC_TIMEZONE="${GENERIC_TIMEZONE:-Europe/Paris}"
export TZ="${TZ:-Europe/Paris}"

if [[ -z "${N8N_ENCRYPTION_KEY:-}" ]]; then
  N8N_ENCRYPTION_KEY="$(openssl rand -hex 32)"
  export N8N_ENCRYPTION_KEY
fi

/usr/bin/desktop_ready

/usr/local/bin/n8n start &
n8n_pid=$!

cleanup() {
  kill "${n8n_pid}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

for _ in $(seq 1 180); do
  if curl --silent --show-error --fail --max-time 2 "${N8N_URL}/healthz" >/dev/null 2>&1; then
    google-chrome --new-window --start-maximized "${N8N_URL}" \
      >/tmp/kasm-n8n-chrome.log 2>&1 &
    wait "${n8n_pid}"
    exit $?
  fi

  if ! kill -0 "${n8n_pid}" 2>/dev/null; then
    break
  fi
  sleep 2
done

wait "${n8n_pid}" 2>/dev/null || true
exit 1
