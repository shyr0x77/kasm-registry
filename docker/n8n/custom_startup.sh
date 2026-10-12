#!/usr/bin/env bash
set -Eeuo pipefail

# Kasm supervise ce script. Il doit donc rester au premier plan pendant toute
# la session au lieu de lancer un enfant puis de se terminer immédiatement.
exec /usr/local/bin/start-kasm-n8n >> /tmp/kasm-n8n-startup.log 2>&1
