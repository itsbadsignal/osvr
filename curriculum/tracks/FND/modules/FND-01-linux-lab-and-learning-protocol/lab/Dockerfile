# osvr-fnd01:1 -- FND-01 smoke-test lab (cJSON CVE-2023-53154, archived vulnerable version).
#
# Requirements:
#   - needs the image osvr-fnd-base:1 to exist locally (build it first)
#   - mount a host directory at /out
#   - run with --network=none
#   - runs as root (inherited from the base)
# The default command is /opt/lab/smoke.sh.
#
# The name below is a short local name. podman resolves it to localhost/osvr-fnd-base:1.
FROM osvr-fnd-base:1

# Source trees, fetched at build time and verified against pinned commits.
# vulnerable: tag v1.7.17.  fixed: the commit that fixes the bug (negative control).
ARG CJSON_REPO=https://github.com/DaveGamble/cJSON
ARG VULN_COMMIT=87d8f0961a01bf09bef98ff89bae9fdec42181ee
ARG FIXED_COMMIT=3ef4e4e730e5efd381be612df41e1ff3f5bb3c32

RUN git clone --quiet "$CJSON_REPO" /src/cjson-vuln \
 && git -C /src/cjson-vuln checkout --quiet "$VULN_COMMIT" \
 && test "$(git -C /src/cjson-vuln rev-parse HEAD)" = "$VULN_COMMIT" \
 && cp -a /src/cjson-vuln /src/cjson-fixed \
 && git -C /src/cjson-fixed checkout --quiet "$FIXED_COMMIT" \
 && test "$(git -C /src/cjson-fixed rev-parse HEAD)" = "$FIXED_COMMIT" \
 && echo "verified cJSON commits: $VULN_COMMIT $FIXED_COMMIT" \
 && git config --system --add safe.directory '*'

COPY harness.c smoke.sh /opt/lab/
RUN chmod +x /opt/lab/smoke.sh

WORKDIR /work
CMD ["/opt/lab/smoke.sh"]
