# osvr-fnd-base:1 -- shared base image for FND-01 .. FND-08.
#
# Build (context = this directory):
#   podman|docker build -t osvr-fnd-base:1 -f Dockerfile .
#
# What this image needs at run time (module images add their own notes):
#   - nothing from the network: run derived images with --network=none
#   - a host directory mounted with -v HOST_DIR:/out when a module writes results
#
# User: the image runs as ROOT inside the container (no USER line).
#   Rootless podman: container root maps to YOUR host user, so files written to a
#     bind mount are owned by you. Nothing more is needed.
#   Rootful Docker: container root is real root, so pass --user "$(id -u):$(id -g)"
#     (the module run.sh does) or the files on the host belong to root.
#     (Docker is untested on the maintainer's machine; see README.md.)
#
# Reproducibility: the base is pinned by digest. Debian packages come from the
# snapshot.debian.org archive at the same instant the pinned image was built
# (20261104T212339Z, visible in the image's own /etc/apt/sources.list.d), so
# the same apt-get install gives the same versions. Installed versions are
# recorded in /etc/osvr-packages.txt, the digest in /etc/osvr-base-digest.
FROM docker.io/library/debian:trixie@sha256:bfc36aecdece0387418759dba474aa856c026ca8087da3606b41b90ab0509c99

ARG BASE_DIGEST=sha256:bfc36aecdece0387418759dba474aa856c026ca8087da3606b41b90ab0509c99
ARG SNAPSHOT=20261104T212339Z
# GEF (gdb extension) tag 2026.01, pinned by commit and by file hash.
ARG GEF_COMMIT=18404074f469c70480aae071fbb77b75a2ed8507
ARG GEF_SHA256=04cdfe961f1e9151933d32cf6b548d9e6a76a1aef8b27c020c575b8d4264ed20

ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8

# Point apt at the dated snapshot (replaces the image's rolling mirrors).
RUN printf '%s\n' \
      'Types: deb' \
      "URIs: http://snapshot.debian.org/archive/debian/${SNAPSHOT}/" \
      'Suites: trixie trixie-updates' \
      'Components: main' \
      'Signed-By: /usr/share/keyrings/debian-archive-keyring.pgp' \
      '' \
      'Types: deb' \
      "URIs: http://snapshot.debian.org/archive/debian-security/${SNAPSHOT}/" \
      'Suites: trixie-security' \
      'Components: main' \
      'Signed-By: /usr/share/keyrings/debian-archive-keyring.pgp' \
      > /etc/apt/sources.list.d/debian.sources \
 && printf 'Acquire::Check-Valid-Until "false";\nAcquire::Retries "5";\n' > /etc/apt/apt.conf.d/99osvr

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      gcc g++ make cmake git gdb binutils file \
      python3 python3-venv ca-certificates curl less nano vim-tiny procps \
 && rm -rf /var/lib/apt/lists/* \
 && dpkg-query -W -f='${Package}=${Version}\n' | sort > /etc/osvr-packages.txt \
 && echo "${BASE_DIGEST}" > /etc/osvr-base-digest

# GEF: single-file gdb extension, loaded for every gdb session via the
# system gdbinit. Remove the last line of /etc/gdb/gdbinit for plain gdb.
RUN mkdir -p /opt/gef /etc/gdb \
 && curl -fsSL -o /opt/gef/gef.py "https://raw.githubusercontent.com/hugsy/gef/${GEF_COMMIT}/gef.py" \
 && echo "${GEF_SHA256}  /opt/gef/gef.py" | sha256sum -c - \
 && echo "${GEF_COMMIT}" > /opt/gef/COMMIT \
 && echo 'source /opt/gef/gef.py' >> /etc/gdb/gdbinit

WORKDIR /work
CMD ["/bin/bash"]
