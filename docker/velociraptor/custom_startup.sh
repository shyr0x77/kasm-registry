#!/usr/bin/env bash
set -u

/usr/local/bin/start-kasm-velociraptor > /tmp/kasm-velociraptor-startup.log 2>&1 &
