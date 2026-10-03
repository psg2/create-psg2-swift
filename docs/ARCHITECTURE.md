# Architecture

```text
Sources/TemplateAppCore/      Domain logic, free of SwiftUI so `swift test` covers it
Sources/TemplateApp/          App entry point and SwiftUI views
Tests/TemplateAppCoreTests/   Swift Testing tests for the core
Resources/                    Info.plist and the icon source
Scripts/                      Build, run, bundle checks, packaging and uninstall
.github/workflows/            CI and tag-based releases
```

`Scripts/build.sh` compiles the app product with SwiftPM, once per architecture
for a universal build, and assembles the `.app` bundle. It copies
`Resources/Info.plist`, stamps the version from `VERSION`, builds the icon set
and signs the bundle ad hoc.
