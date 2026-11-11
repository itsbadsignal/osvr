# Contributing

OSVR is a list of existing resources, not a course. Contributions are about which resources are on it, in what order, and whether the links still work.

## Ways to help

- **Report a dead or moved link**: open an issue with the section, the link, and what you see.
- **Propose a resource**: open an issue or PR with:
  - the link, title, author/provider and cost (with price if paid);
  - which section and which row it would add to or replace;
  - why it is better than what is there (exercises? more current? covers a gap?);
  - any stated effort (hours, challenge count) from the provider's own page.
- **Fill a gap**: the Embedded/firmware, Mobile and Hypervisor specialisations have only a few rows, with thin descriptions. Stated effort, last-updated dates and better free courses are all wanted.

## Rules for a resource

1. You have opened the page yourself and it says what the row claims.
2. It teaches by doing, or it is the clear reference for its topic.
3. It is legally accessible. No pirated copies.
4. If it is dated (old mitigations, unmaintained), the Notes column says so.
5. Paid is fine if it is clearly the best option; give the price and a free alternative if one exists.
6. Effort comes from the provider, not from your estimate.

## Format

Rows in README.md use `| | Resource | Cost | Effort | Notes |`, where the first column is `Core`, `Alt`, `Ref`, `Practice`, `Read` or `Paid` (definitions in [CLAUDE.md](CLAUDE.md)).

## Commit messages

```
<type>(<scope>): <summary>

<body: why the change; for add/replace, what it beats>

Verified: YYYY-MM-DD
```

- **Subject**: lowercase, imperative ("add", not "added"), max 72 characters, no full stop.
- **Body**: optional, separated by a blank line.
- **Verified trailer**: required for `add` and `replace`. It is the date you opened the page and confirmed it says what the row claims.
- No em or en dashes anywhere.

| Type | Use for |
|---|---|
| `add` | a new resource row |
| `remove` | a resource row taken out |
| `replace` | one resource swapped for another in the same slot |
| `fix` | a dead or moved link, or a wrong fact (price, effort, author) |
| `update` | a note, caveat or "last checked" date |
| `reorder` | rows or sections moved, nothing added or removed |
| `research` | files under `research/` |
| `docs` | README intro, FAQ, CONTRIBUTING, CLAUDE.md |
| `chore` | hooks, config, tooling |

Scopes: `foundations`, `re`, `bx`, `vd`, `pro`, `kernel`, `windows`, `browser`, `embedded`, `mobile`, `hv`, `final`, `extras`, or `repo` for changes that cross sections.

Examples:

```
add(vd): add oss-fuzz introspector as a ref row

Shows which code a project's fuzzers never reach, which is where
to start an audit.

Verified: 2026-11-11
```

```
fix(bx): update ropemporium link after site move
```

### Hooks

The repo ships hooks in `.githooks/`. Enable them once per clone:

```sh
git config core.hooksPath .githooks
git config commit.template .gitmessage
```

- `commit-msg` checks the format above.
- `pre-commit` checks staged Markdown for em/en dashes, and README rows for unknown labels or `http://` links.

Both are offline and fast. Bypass in an emergency with `git commit --no-verify`.
