# Working agreements

- Keep domain logic in TemplateAppCore, free of SwiftUI, and views in TemplateApp.
- Write code, comments, documentation and PRs in English.
- Test observable behavior through module interfaces or the built app's
  command line. Don't assert internal call order or source text.
- Run `mise run check` before publishing code changes. `mise tasks` lists the rest.
- Open pull requests ready for review with why, what changed, validation and
  limitations. Monitor checks and bot review comments.
- Use GitHub-hosted runners, pin actions by full commit SHA, keep write
  permissions on the release job only, and never publish local credentials.
