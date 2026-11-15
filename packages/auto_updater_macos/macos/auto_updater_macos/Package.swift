// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "auto_updater_macos",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "auto-updater-macos", targets: ["auto_updater_macos"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.1")
    ],
    targets: [
        .target(
            name: "auto_updater_macos",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ]
        )
    ]
)
