#!/usr/bin/env bash
set -u

/usr/local/bin/start-kasm-n8n > /tmp/kasm-n8n-startup.log 2>&1 &
