# Template App

A native macOS app in SwiftUI.

## Install

Download the latest release from GitHub Releases, unzip it and move
**Template App.app** to Applications. It needs macOS 14 or later.

Releases are ad hoc signed and not notarized. Check the download first:

```sh
shasum -a 256 -c TemplateApp-X.Y.Z-macos-universal.zip.sha256
```

If macOS blocks the first launch, open **System Settings → Privacy & Security**
and choose **Open Anyway**.

## Build from source

You need Swift 6 from Xcode or the Command Line Tools, and [mise](https://mise.jdx.dev).

```sh
mise install
mise run run
```

[Development](docs/development.md) lists every task. [Architecture](docs/ARCHITECTURE.md)
and [Releasing](docs/RELEASING.md) cover the layout and how versions ship.
