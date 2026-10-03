# create-psg2-swift

A starting point for native macOS apps in Swift, shared by psg2 projects such as
[colima-mini](https://github.com/psg2/colima-mini) and
[open-appshot](https://github.com/psg2/open-appshot). `setup.sh` replaces this
README with the app's own, `docs/APP_README.md`.

## Start a new app

```sh
git clone https://github.com/pgsereno/create-psg2-swift.git my-app
cd my-app
./setup.sh                      # asks for the name and bundle identifier
./setup.sh "My App" com.example.my-app   # or pass them
```

The script replaces every placeholder, renames the Swift targets, starts a fresh
Git history, installs the pinned tools and the pre-push hook, and runs
`mise run ci`.

| Placeholder | Becomes, for "My App" |
| --- | --- |
| `Template App` | `My App` (display and bundle name) |
| `TemplateApp`, `TemplateAppCore`, `TemplateAppCoreTests` | `MyApp`, `MyAppCore`, `MyAppCoreTests` |
| `template-app` | `my-app` |
| `com.psg2.template-app` | the bundle identifier you enter |
| `TEMPLATE_APP_` | `MY_APP_` (environment variables) |

## What every app gets

- **SwiftPM, no Xcode project.** A `Core` library for logic, the app target and
  Swift Testing tests. Every target compiles with warnings as errors, in Swift 5
  language mode.
- **mise** pins ShellCheck, actionlint, Gitleaks and Lefthook, and defines the
  tasks: `format`, `lint` (`lint:swift`, `lint:shell`, `lint:actions`,
  `lint:plist`), `test:unit`, `test:app`, `test`, `ci`, `scan-secrets`, `check`,
  `build`, `install`, `uninstall`, `run`, `package-release`, `clean`, `hooks`.
- **Formatting.** swift-format with four spaces and 140 columns, plus `.editorconfig`.
- **A versioned `Resources/Info.plist`.** The build stamps `VERSION` into it.
  Output goes to `build/`, and releases to `build/release/`.
- **GitHub.** CI with a Gitleaks job, `mise run ci` on macOS 26, and `mise run test`
  on macOS 15 for Apple Silicon and Intel. A tag-triggered release workflow.
  Dependabot for actions, every action pinned by SHA, and read-only permissions
  by default.
- **Repository files.** README, AGENTS.md, CONTEXT.md (domain terms), CONTRIBUTING,
  SECURITY, CODE_OF_CONDUCT, issue and PR templates, and an MIT license.

## Optional additions

Add these when an app needs them:

- `lint:python` when the app bundles a Python script.
- `smoke` tasks for checks that need macOS permissions and can only run locally.
- Developer ID signing and notarization in `Scripts/package-release.sh`.
- `.coderabbit.yaml` with path instructions about the app's risks.
