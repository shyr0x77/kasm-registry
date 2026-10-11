#!/usr/bin/env bash
set -Eeuo pipefail

readonly AUTOPSY_BIN=/opt/autopsy-current/bin/autopsy
readonly AUTOPSY_USERDIR=/home/kasm-user/.autopsy
readonly AUTOPSY_CACHEDIR=/home/kasm-user/.cache/autopsy

mkdir -p /cases "${AUTOPSY_USERDIR}" "${AUTOPSY_CACHEDIR}"

/usr/bin/desktop_ready
cd /cases

exec "${AUTOPSY_BIN}" \
  --nosplash \
  --userdir "${AUTOPSY_USERDIR}" \
  --cachedir "${AUTOPSY_CACHEDIR}"

