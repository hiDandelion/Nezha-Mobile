// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NezhaMobileData",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
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
