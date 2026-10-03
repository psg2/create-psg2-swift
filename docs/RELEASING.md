# Releasing

1. Update `VERSION` and `docs/release-notes.md`, then merge.
2. Tag the merge commit and push the tag:

   ```sh
   git tag "v$(cat VERSION)"
   git push origin "v$(cat VERSION)"
   ```

The release workflow checks that the tag matches `VERSION`, runs `mise run ci`,
builds a universal app, extracts the archive and checks the app inside it (checksum,
signature, versions, both architectures), then publishes the ZIP and its SHA-256
checksum with the release notes.

To build the archive in `build/release/` without publishing:

```sh
TEMPLATE_APP_RELEASE_SIGNING=adhoc mise run package-release
```

The script refuses to run without a signing mode. Add Developer ID signing and
notarization to it once you have a certificate.
