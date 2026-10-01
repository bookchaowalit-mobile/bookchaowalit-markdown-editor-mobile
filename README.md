# Markdown Editor — Mobile

SwiftUI app for **Markdown Editor** — write Markdown on the go.

Part of [Chaowalit Greepoke](https://bookchaowalit.com)'s 101 Portfolio Projects.

## Status

This is a Swift package, not yet a shippable app:

- `Sources/MarkdownEditorCore` — Foundation-only domain logic, unit-tested in
  `Tests/MarkdownEditorCoreTests` (XCTest).
- `Sources/MarkdownEditorUI` — SwiftUI tab shell (Home / Explore / Profile). It does not
  use `MarkdownEditorCore` yet, and there is no Xcode app target (`@main`) yet.

The code has **not been compiled outside CI** (it was written without a Swift
toolchain); the macOS CI job is the first real build. See
[docs/UPGRADE-PLAN.md](docs/UPGRADE-PLAN.md).

## Core features (`MarkdownEditorCore`)

- Document outline from ATX headings (ignores fenced code and `#hashtags`, strips closing `#`s) with GitHub-style, de-duplicated anchors
- Word/character counts over prose only (code fences excluded) and reading time
- Toggle bold/italic/code markers around a selection (wrap or unwrap, clamped offsets, caret placed inside an empty pair)
- Task list checkbox toggling (`- [ ]` ↔ `- [x]`)

## Tech Stack

- **UI:** SwiftUI (iOS 17+ / macOS 14+)
- **Language:** Swift 5.10
- **Tests:** XCTest via SwiftPM

## Getting Started

```bash
swift build
swift test          # runs MarkdownEditorCoreTests
open Package.swift  # opens in Xcode 15+
```

CI (`.github/workflows/build.yml`, macOS 14) runs `swift build` and
`swift test`; failures fail the workflow.

## Related

- **Frontend:** [bookchaowalit-website/markdown-editor-frontend](https://github.com/bookchaowalit-website/bookchaowalit-markdown-editor-frontend)
- **Portfolio:** [bookchaowalit.com](https://bookchaowalit.com)

## License

MIT
