"""Parse the first AddressSanitizer report in a text. Python 3 stdlib only.

Fields returned by parse(): kind, op, size, offset, region, frame0, alloc, ubsan.

frame0 rule: frame0 is the first frame of the access stack that is not a sanitizer
interceptor or a libc frame, that is, the first frame in the program's own source.
A frame is skipped when its function name starts with __asan, __interceptor, __sanitizer,
__ubsan or __libc_, when its source path is inside the sanitizer runtime (libsanitizer,
sanitizer_common, /asan/) or the C library (../csu, ../sysdeps, ../string, ../libio,
../stdlib, ../malloc, /glibc), or when it has no source location at all (a shared
library frame such as libc.so.6). So memset, snprintf and printf_common frames are
skipped and frame0 names the caller in your code. If no frame qualifies (a build
without -g), frame0 falls back to the first frame printed.

alloc rule: heap -> first function of the allocation stack that is not an allocator
(malloc, calloc, realloc, strdup, OpenSSL CRYPTO_malloc/zalloc/realloc, interceptor frames); stack and global -> the variable name.
Global reports ("is located N bytes after global variable 'NAME' defined in 'FILE:L:C' ...
of size S") give region = S, alloc = NAME, offset = N.
"""
import re

SKIP_FUNC = re.compile(r"^(__asan|__interceptor|__sanitizer|__ubsan|__libc_)")
SKIP_PATH = re.compile(r"libsanitizer|sanitizer_common|/asan/|^(\.\./)+(csu|sysdeps|string|libio|stdlib|malloc)/|/glibc")
ALLOCATOR = re.compile(r"(^|_)(malloc|calloc|realloc|memalign|posix_memalign|aligned_alloc|strdup|strndup|CRYPTO_malloc|CRYPTO_zalloc|CRYPTO_realloc)$|interceptor|^operator new|^__asan|^__sanitizer|^__libc_")


def _frame(line):
    """'#1 0x.. in func path/file.c:12:5' -> (func, file, line, fullpath) or None."""
    m = re.match(r"\s*#\d+\s+0x[0-9a-f]+\s+in\s+(\S+)\s*(.*)$", line)
    if not m:
        return None
    func, rest = m.group(1), m.group(2)
    loc = re.search(r"([^\s()]*?([^/\s()]+)):(\d+)(?::\d+)?\s*$", rest)
    if loc:
        return (func, loc.group(2), int(loc.group(3)), loc.group(1))
    return (func, None, None, None)


def _is_program_frame(f):
    return f[3] is not None and not SKIP_FUNC.search(f[0]) and not SKIP_PATH.search(f[3])


def parse(text):
    """Return dict with kind, op, size, offset, region, frame0, alloc, ubsan; or None."""
    lines = text.splitlines()
    start = next((i for i, l in enumerate(lines) if "ERROR: AddressSanitizer:" in l), None)
    ubsan = [l.strip() for l in lines if "runtime error:" in l]
    if start is None:
        return None
    r = {"ubsan": ubsan}
    r["kind"] = re.search(r"AddressSanitizer:\s*(\S+)", lines[start]).group(1)
    body = lines[start:]
    for l in body:
        m = re.match(r"(READ|WRITE) of size (\d+)", l)
        if m:
            r["op"], r["size"] = m.group(1), int(m.group(2))
            break
    # frame0: first program frame of the access stack (see the module docstring)
    frames, seen_op = [], False
    for l in body:
        if re.match(r"(READ|WRITE) of size", l):
            seen_op = True
            continue
        if seen_op:
            f = _frame(l)
            if f:
                frames.append(f)
            elif frames:
                break
    if frames:
        f = next((x for x in frames if _is_program_frame(x)), frames[0])
        r["frame0"] = (f[0], f[2])
    txt = "\n".join(body)
    m = re.search(r"is located (\d+) bytes (after|before|inside of) (\d+)-byte region", txt)
    g = re.search(r"is located (\d+) bytes (after|before|inside of) global variable '([^']+)' defined in '[^']*' \(0x[0-9a-f]+\) of size (\d+)", txt)
    if g and not m:
        r["offset"] = (int(g.group(1)), "inside" if g.group(2).startswith("inside") else g.group(2))
        r["region"] = int(g.group(4))
        r["alloc"] = (g.group(3), None)
    elif m:
        r["offset"] = (int(m.group(1)), "inside" if m.group(2).startswith("inside") else m.group(2))
        r["region"] = int(m.group(3))
        alloc_i = next((i for i, l in enumerate(body) if l.startswith("allocated by thread")), None)
        if alloc_i is not None:
            for l in body[alloc_i + 1:]:
                if not l.strip().startswith("#"):
                    break
                f = _frame(l)
                if f and not ALLOCATOR.search(f[0]):
                    r["alloc"] = (f[0], f[2])
                    break
    else:
        # stack/global object: "[a, b) 'name' (line N) <== Memory access at offset K ..."
        m = re.search(r"\[(\d+), (\d+)\) '([^']+)'[^\n]*<== Memory access at offset (\d+) (overflows|underflows|is inside)", txt)
        if m:
            a, b, name, off = int(m.group(1)), int(m.group(2)), m.group(3), int(m.group(4))
            r["region"] = b - a
            r["alloc"] = (name, None)
            if off >= b:
                r["offset"] = (off - b, "after")
            elif off < a:
                r["offset"] = (a - off, "before")
            else:
                r["offset"] = (off - a, "inside")
    return r
