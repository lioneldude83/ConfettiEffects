// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConfettiEffects",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "ConfettiEffects",
            targets: ["ConfettiEffects"]
        ),
    ],
    targets: [
        .target(
            name: "ConfettiEffects",
            resources: [
                .process("Shaders"),
            ]
        ),
        .testTarget(
            name: "ConfettiEffectsTests",
            dependencies: ["ConfettiEffects"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
