#!/bin/bash
# Remove the FND-02 image(s). Your files in ~/osvr-work/fnd02 are NOT touched. FULL=1 also removes the base.
set -u
ENGINE=${ENGINE:-$(command -v podman || command -v docker || true)}
[ -n "$ENGINE" ] || exit 0
"$ENGINE" rmi osvr-fnd02-iperf:1 2>/dev/null
"$ENGINE" rmi osvr-fnd02:1 2>/dev/null
[ "${FULL:-0}" = 1 ] && "$ENGINE" rmi osvr-fnd-base:1 2>/dev/null
echo "reset done (images removed; $HOME/osvr-work/fnd02 untouched)"
exit 0
