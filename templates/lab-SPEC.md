# Lab spec: <MODULE_ID>

Target: <software>   Version: <pinned>   Source: <url from research/, with checksum if known>
Kind: docker | qemu-user | qemu-system | vm
Bug: <class, location>   Fix reference: <commit / advisory>

## Expected vulnerable behaviour
<what a learner should observe, e.g. crash with SIGSEGV at <function> when sending N bytes>

## Mitigation build matrix
| Variant | Flags / config | Used by |
|---|---|---|
| easy | e.g. -fno-stack-protector -no-pie -z norelro | struggle challenge, drills |
| real | distro defaults | project |

## Checker idea
<how to verify outcome without revealing the solution, e.g. flag file readable only by target uid>

## Limits
RAM: N GB   Disk: N GB   Network: none at runtime | <reason>

## Implementation notes (lab-engineer appends)
