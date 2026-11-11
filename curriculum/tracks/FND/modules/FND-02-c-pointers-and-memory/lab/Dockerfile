# osvr-fnd02:1 -- FND-02 lab: C pointers and memory. Exercise programs plus iperf source for reading.
#
# Build, from the repository root, base image first (FND-01 builds it):
#   <engine> build -t osvr-fnd-base:1 -f labs/shared/fnd-base/Dockerfile labs/shared/fnd-base
#   <engine> build -t osvr-fnd02:1    -f <this dir>/Dockerfile           <this dir>
# Building needs the network (git clone of iperf). Running does not.
#
# Run requirements (run.sh does all of this):
#   - --network=none; no ports are used
#   - mount a host dir at /work/fnd02 with -v HOST_DIR:/work/fnd02 ; only that dir survives the container
#   - the container user is root (inherited from the base). Rootless podman maps it to you.
#     Under Docker add --user "$(id -u):$(id -g)" (UNTESTED: Docker is not installed on the maintainer's machine).
#   - for gdb to switch ASLR off, the default seccomp profile blocks personality(2):
#     add --security-opt seccomp=unconfined. gdb itself needs no extra capability under rootless podman.
#
# Contents: /opt/osvr/fnd02/src (exercise programs), /opt/osvr/fnd02/tools (predict-check, grade-repro),
# /src/iperf (full clone, history and tags, checked out at the fix commit).
FROM osvr-fnd-base:1

ARG IPERF_REPO=https://github.com/esnet/iperf
ARG IPERF_FIX=4e5313bab0b9b3fe03513ab54f722c8a3e4b7bdf
ARG IPERF_PARENT=4eab661da0bbaac04493fa40164e928c6df7934a

RUN git clone --quiet "$IPERF_REPO" /src/iperf \
 && git -C /src/iperf -c advice.detachedHead=false checkout --quiet "$IPERF_FIX" \
 && test "$(git -C /src/iperf rev-parse HEAD)" = "$IPERF_FIX" \
 && git -C /src/iperf cat-file -e "${IPERF_PARENT}^{commit}" \
 && test "$(git -C /src/iperf rev-parse "${IPERF_FIX}^")" = "$IPERF_PARENT" \
 && git -C /src/iperf cat-file -e 3.19.1^{commit} \
 && git config --system --add safe.directory '*' \
 && echo "verified iperf commits: $IPERF_FIX $IPERF_PARENT"

COPY src/ /opt/osvr/fnd02/src/
COPY tools/ /opt/osvr/fnd02/tools/
RUN chmod +x /opt/osvr/fnd02/tools/predict-check /opt/osvr/fnd02/tools/grade-repro /opt/osvr/fnd02/tools/realbug.py /opt/osvr/fnd02/tools/tests/run_tests.sh

WORKDIR /work/fnd02
CMD ["/bin/bash"]
