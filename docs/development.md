# Development

```sh
mise install     # pinned shellcheck, actionlint, gitleaks and lefthook
mise run hooks   # pre-push hook that runs `mise run check`
```

`mise tasks` lists every task. The common ones:

| Task | What it does |
| --- | --- |
| `mise run run` | Builds and opens the app; arguments pass through |
| `mise run install` | Builds and copies the app to `~/Applications` |
| `mise run uninstall` | Removes the installed app and keeps its preferences |
| `mise run format` | Rewrites Swift sources with swift-format |
| `mise run lint` | Formatting, ShellCheck, actionlint and Info.plist |
| `mise run test:unit` | `swift test` |
| `mise run test:app` | Builds, then checks the bundle and `--version` |
| `mise run test` | `test:unit`, then `test:app` |
| `mise run ci` | `lint` and `test`, as CI runs them |
| `mise run check` | `ci` plus a Gitleaks scan of the tree and history |

CI runs `mise run ci` on macOS 26, `mise run test` on macOS 15 for Apple Silicon
and Intel, and Gitleaks on Linux.
