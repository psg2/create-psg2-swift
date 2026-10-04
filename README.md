# create-psg2-swift

A starting point for native macOS apps in Swift, shared by psg2 projects such as
[colima-mini](https://github.com/psg2/colima-mini) and
[open-appshot](https://github.com/psg2/open-appshot). `Scripts/setup.sh` replaces this
README with the app's own, `docs/APP_README.md`.

## Start a new app

Create the app's repository from this template, then run the setup script:

```sh
gh repo create psg2/my-app --template psg2/create-psg2-swift --private --clone
cd my-app
./Scripts/setup.sh                                           # asks for each value
./Scripts/setup.sh "My App" com.example.my-app psg2/my-app   # or pass them
```

The "Use this template" button on GitHub works the same way. The script keeps
the repository and its `origin` remote and commits the setup on the current
branch. Push it with `git push`.

To start without a GitHub repository, clone the template instead:

```sh
git clone https://github.com/psg2/create-psg2-swift.git my-app
cd my-app
./Scripts/setup.sh
```

When `origin` points at create-psg2-swift, or there is no `origin`, the script
deletes the template's history and starts a new repository with one commit.
Add your own remote afterward.

In both cases the script replaces every placeholder, renames the Swift targets,
installs the pinned tools and the pre-push hook, and runs `mise run ci`.

| Placeholder | Becomes, for "My App" |
| --- | --- |
| `Template App` | `My App` (display and bundle name) |
| `TemplateApp`, `TemplateAppCore`, `TemplateAppCoreTests` | `MyApp`, `MyAppCore`, `MyAppCoreTests` |
| `template-app` | `my-app` |
| `com.psg2.template-app` | the bundle identifier you enter |
| `TEMPLATE_APP_` | `MY_APP_` (environment variables) |
| `psg2/template-app` | the GitHub repository you enter |

## What every app gets

- **SwiftPM, no Xcode project.** A `Core` library for logic, the app target and
  Swift Testing tests. Every target compiles with warnings as errors, in Swift 5
  language mode.
- **mise** pins ShellCheck, actionlint, Gitleaks and Lefthook, and defines the
  tasks: `format`, `lint` (`lint:swift`, `lint:shell`, `lint:actions`,
  `lint:plist`), `test:unit`, `test:app` (signature, icon, versions, minimum
  macOS and the `--version` contract), `test`, `ci`, `scan-secrets`, `check`,
  `build`, `install`, `uninstall`, `run`, `package-release`, `clean`, `hooks`.
- **Formatting.** swift-format with four spaces and 140 columns, plus `.editorconfig`.
- **A versioned `Resources/Info.plist`.** The build stamps `VERSION` into both
  version keys, so a release only bumps `VERSION`.
  Output goes to `build/`, and releases to `build/release/`.
- **GitHub.** CI with a Gitleaks job, `mise run ci` on macOS 26, and `mise run test`
  on the minimum macOS (14, Apple Silicon) and on Intel. A tag-triggered release workflow.
  Dependabot for actions, every action pinned by SHA, and read-only permissions
  by default.
- **Repository files.** README, AGENTS.md, CONTEXT.md (domain terms), CONTRIBUTING,
  SECURITY, CODE_OF_CONDUCT, issue and PR templates, `.coderabbit.yaml`, a
  `.gitignore` that covers signing material and `.env` files, and an MIT license.

## Optional additions

Add these when an app needs them:

- `lint:python` when the app bundles a Python script.
- `smoke` tasks for checks that need macOS permissions (TCC) and can only run
  locally. Follow open-appshot's pattern: a standalone Swift fixture in
  `Tests/Fixtures/` that the smoke script builds, a task that depends on `build`
  or `install`, a script that removes only what it created, and a README note
  that it runs locally only.
- Developer ID signing and notarization in `Scripts/package-release.sh`.
- More `.coderabbit.yaml` path instructions about the app's own risks.
