// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Markdown Editor",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Markdown Editor", targets: ["Markdown Editor"])
    ],
    targets: [
        .target(name: "Markdown Editor", path: "Sources")
    ]
)
