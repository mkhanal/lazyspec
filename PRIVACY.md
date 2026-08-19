# Privacy

**lazyspec collects nothing, stores nothing, and sends nothing anywhere.**

There is no server, no account, no telemetry and no analytics. There is
nothing to opt out of, because there is nothing switched on.

## What it is

Three markdown files and a standing instruction. The plugin declares no
hooks, no MCP servers and no executables, and it makes no network
requests of any kind. You can verify each of those in a checkout:

```
git ls-files skills          # three SKILL.md files, nothing else
grep -r http skills/         # no matches
```

## What it reads and writes

Your agent does the reading and writing, in your repository, using the
tools it already has and the permissions you already gave it. lazyspec
only tells it what to read and when:

- **Reads** your specifications, your tests, and `lazyspec.md` if you
  have one.
- **Writes** requirements and their tests, when you run `/lazyspec`.
- **Writes once at install**, when `/lazyspec-setup` puts the standing
  instruction into your rules file — and only after proposing where and
  waiting for you to agree.

Nothing leaves your machine that was not already leaving it. Whatever
your coding agent already sends to its own provider, it continues to
send; lazyspec adds no destination, no request and no payload of its
own. That relationship is between you and whoever makes your agent, and
is governed by their privacy policy, not this one.

## Third parties

None. lazyspec integrates with no service and depends on no package.

## Contact

Questions, or something here that is not true of what you observe:
<https://github.com/mkhanal/lazyspec/issues>
