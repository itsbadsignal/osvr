#!/usr/bin/env python3
"""realbug.py VARIANT HARNESS.c      (inside osvr-fnd02-iperf:1 only)

Compile HARNESS.c against the ASan-built iperf_auth.o of one iperf tree, run it, print the output.
  vuln   /src/iperf-vuln   at 4eab661d (vulnerable parent)
  fixed  /src/iperf-fixed  at 4e5313ba (fix)
Build line (the same one check.sh realbug uses):
  gcc -g -O1 -fsanitize=address -fno-omit-frame-pointer -I<tree>/src HARNESS.c <tree>/src/iperf_auth.o -lssl -lcrypto -o OUT
The program runs from a scratch directory holding copies of private.pem and public.pem, so it can open
"private.pem" by relative name. ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 (the default frame-pointer unwinder
stops inside libcrypto, so the allocation stack would end at CRYPTO_malloc). Nothing in /src is written.
Python 3 stdlib only.
"""
import os
import shutil
import subprocess
import sys
import tempfile

TREES = {"vuln": ("/src/iperf-vuln/src", "4eab661d"), "fixed": ("/src/iperf-fixed/src", "4e5313ba")}
CFLAGS = ["-g", "-O1", "-fsanitize=address", "-fno-omit-frame-pointer"]


def available():
    return all(os.path.isfile(t + "/iperf_auth.o") for t, _ in TREES.values())


def build_cmd(variant, src, out):
    tree = TREES[variant][0]
    return ["gcc", *CFLAGS, "-I" + tree, src, tree + "/iperf_auth.o", "-lssl", "-lcrypto", "-o", out]


def build(variant, src, workdir):
    """Compile src (copied into workdir first). Return (exe or None, compiler output)."""
    local = os.path.join(workdir, "harness-%s.c" % variant)
    shutil.copyfile(src, local)
    exe = os.path.join(workdir, "harness-" + variant)
    p = subprocess.run(build_cmd(variant, local, exe), stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                       text=True, errors="replace")
    return (exe if os.path.exists(exe) else None), p.stdout


def run(variant, exe, workdir, timeout=20):
    """Run exe in a scratch dir with the keys. Return CompletedProcess (stdout, stderr separate) or None on timeout."""
    tree = TREES[variant][0]
    cwd = os.path.join(workdir, "run-" + variant)
    os.makedirs(cwd, exist_ok=True)
    for k in ("private.pem", "public.pem"):
        shutil.copyfile(os.path.join(tree, k), os.path.join(cwd, k))
    env = dict(os.environ, ASAN_OPTIONS="detect_leaks=0:fast_unwind_on_malloc=0")
    try:
        return subprocess.run([exe], cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
                              errors="replace", timeout=timeout, env=env)
    except subprocess.TimeoutExpired:
        return None


def main(argv):
    if len(argv) != 3 or argv[1] not in TREES or not os.path.isfile(argv[2]):
        print(__doc__, file=sys.stderr)
        return 2
    if not available():
        print("iperf ASan trees not found: this needs the osvr-fnd02-iperf:1 image (IPERF=1 ./build.sh)", file=sys.stderr)
        return 2
    v = argv[1]
    with tempfile.TemporaryDirectory() as d:
        exe, out = build(v, argv[2], d)
        print("+", " ".join(build_cmd(v, argv[2], "OUT")))
        if exe is None:
            print(out, end="")
            return 1
        if out:
            print(out, end="")
        r = run(v, exe, d)
        if r is None:
            print("timeout")
            return 1
        sys.stdout.write(r.stdout)
        sys.stderr.write(r.stderr)
        print("exit status", r.returncode)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
