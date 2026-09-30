// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MarkdownEditor",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MarkdownEditorCore", targets: ["MarkdownEditorCore"]),
        .library(name: "MarkdownEditorUI", targets: ["MarkdownEditorUI"]),
    ],
    targets: [
        // Foundation-only domain logic; no SwiftUI so it also builds on Linux.
        .target(name: "MarkdownEditorCore", path: "Sources/MarkdownEditorCore"),
        .target(name: "MarkdownEditorUI", dependencies: ["MarkdownEditorCore"], path: "Sources/MarkdownEditorUI"),
        .testTarget(name: "MarkdownEditorCoreTests", dependencies: ["MarkdownEditorCore"], path: "Tests/MarkdownEditorCoreTests"),
    ]
)
