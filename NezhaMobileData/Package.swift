// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NezhaMobileData",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "NezhaMobileData",
            targets: ["NezhaMobileData"]
        ),
    ],
    targets: [
        .target(
            name: "NezhaMobileData"
        ),
    ]
)
