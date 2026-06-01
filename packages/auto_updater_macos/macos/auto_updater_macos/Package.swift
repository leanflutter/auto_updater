// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "auto_updater_macos",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "auto-updater-macos", targets: ["auto_updater_macos"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.9.2")
    ],
    targets: [
        .target(
            name: "auto_updater_macos",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Sparkle", package: "Sparkle")
            ]
        )
    ]
)
