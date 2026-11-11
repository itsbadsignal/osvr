#!/bin/bash
# Remove only the osvr-fnd03:1 image. Your files in ~/osvr-work/fnd03 and the base image are NOT touched.
ENGINE=${ENGINE:-$(command -v podman || command -v docker || true)}
[ -n "$ENGINE" ] || exit 0
"$ENGINE" rmi osvr-fnd03:1 2>/dev/null
echo "reset done (osvr-fnd03:1 removed; $HOME/osvr-work/fnd03 and the base image untouched)"
exit 0
