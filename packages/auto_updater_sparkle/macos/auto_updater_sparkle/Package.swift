// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "auto_updater_sparkle",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "auto-updater-sparkle", targets: ["auto_updater_sparkle"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.1")
    ],
    targets: [
        .target(
            name: "auto_updater_sparkle",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ]
        )
    ]
)
