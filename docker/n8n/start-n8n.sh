#!/usr/bin/env bash
set -Eeuo pipefail

readonly N8N_URL=http://127.0.0.1:5678
readonly N8N_DATA_DIR=/home/kasm-user/.n8n

log() {
  printf '[%s] %s\n' "$(date --iso-8601=seconds)" "$*"
}

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

log "Attente du bureau Kasm"
/usr/bin/desktop_ready

log "Node $(node --version), n8n $(n8n --version)"
log "Démarrage de n8n sur ${N8N_URL}"
/usr/local/bin/n8n start &
n8n_pid=$!

cleanup() {
  kill "${n8n_pid}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

ready=false
for _ in $(seq 1 180); do
  if curl --silent --show-error --fail --max-time 2 "${N8N_URL}/healthz" >/dev/null 2>&1; then
    ready=true
    log "n8n est prêt"
    break
  fi

  if ! kill -0 "${n8n_pid}" 2>/dev/null; then
    log "n8n s'est arrêté avant de devenir disponible"
    break
  fi
  sleep 2
done

# Toujours ouvrir Chrome. Si n8n a échoué, la page d'erreur et le journal
# /tmp/kasm-n8n-startup.log rendent le problème visible au lieu d'un fond vide.
log "Ouverture de Chrome vers ${N8N_URL} (ready=${ready})"
google-chrome --new-window --start-maximized "${N8N_URL}" \
  >/tmp/kasm-n8n-chrome.log 2>&1 &

set +e
wait "${n8n_pid}"
n8n_status=$?
set -e
log "n8n s'est arrêté avec le code ${n8n_status}"
exit "${n8n_status}"
