# osvr-fnd03:1 -- FND-03 lab: building cJSON with CMake, ASan/UBSan and debugging it with gdb.
#
# Build, from the repository root, base image first (FND-01 builds it):
#   <engine> build -t osvr-fnd-base:1 -f labs/shared/fnd-base/Dockerfile labs/shared/fnd-base
#   <engine> build -t osvr-fnd03:1    -f <this dir>/Dockerfile           <this dir>
# Building needs the network (git clone of cJSON). Running does not.
#
# Run requirements (run.sh does all of this):
#   - --network=none; no ports are used
#   - mount a host dir at /work/fnd03 with -v HOST_DIR:/work/fnd03 ; only that dir survives the container
#   - the container user is root (inherited from the base). Rootless podman maps it to you.
#     Under Docker add --user "$(id -u):$(id -g)".
#   - gdb works with default flags under rootless podman. To make gdb switch ASLR off, the default
#     seccomp profile blocks personality(2): add --security-opt seccomp=unconfined (run.sh: ASLR_OFF=1).
#   - do not set a virtual-memory ulimit (AddressSanitizer reserves a large address range)
#
# Contents: /src/cjson (full clone, detached at the pinned commit; treat as read-only),
# /src/cjson.newest (newest upstream commit at image build time), /opt/osvr/fnd03/{src,mystery,tools}.
FROM osvr-fnd-base:1

ARG CJSON_REPO=https://github.com/DaveGamble/cJSON
ARG CJSON_COMMIT=87d8f0961a01bf09bef98ff89bae9fdec42181ee

RUN git clone --quiet "$CJSON_REPO" /src/cjson \
 && git -C /src/cjson log -1 --format='%H %cs' origin/HEAD > /src/cjson.newest \
 && git -C /src/cjson -c advice.detachedHead=false checkout --quiet "$CJSON_COMMIT" \
 && test "$(git -C /src/cjson rev-parse HEAD)" = "$CJSON_COMMIT" \
 && git -C /src/cjson rev-parse --verify --quiet 'v1.7.18^{commit}' >/dev/null \
 && git -C /src/cjson rev-parse --verify --quiet 'v1.7.19^{commit}' >/dev/null \
 && git config --system --add safe.directory '*' \
 && chmod -R a-w /src/cjson \
 && echo "verified cJSON commit $CJSON_COMMIT; newest upstream: $(cat /src/cjson.newest)"

COPY src/ /opt/osvr/fnd03/src/
COPY tools/ /opt/osvr/fnd03/tools/
COPY mystery/ /tmp/mystery-build/
# Drill 2 binaries. The build script checks every answer-key field against the real artefacts,
# then only the salted-hash key is kept (the plain key and the source are deleted).
RUN bash /tmp/mystery-build/build-mystery.sh /opt/osvr/fnd03/mystery \
 && python3 /opt/osvr/fnd03/tools/make-key /opt/osvr/fnd03/.key.plain /opt/osvr/fnd03/tools/.mystery-key \
 && rm -rf /tmp/mystery-build /opt/osvr/fnd03/.key.plain /opt/osvr/fnd03/tools/make-key \
 && chmod +x /opt/osvr/fnd03/tools/*

WORKDIR /work/fnd03
CMD ["/bin/bash"]
