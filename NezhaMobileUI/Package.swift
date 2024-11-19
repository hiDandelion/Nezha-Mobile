// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NezhaMobileUI",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "NezhaMobileUI",
            targets: ["NezhaMobileUI"]
        ),
    ],
    targets: [
        .target(
            name: "NezhaMobileUI"
        ),
    ]
)
