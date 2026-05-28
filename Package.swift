// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PLSwiftApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PLSwiftApp", targets: ["PLSwiftApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "PLSwiftApp",
            dependencies: []
        ),
        .testTarget(
            name: "PLSwiftAppTests",
            dependencies: ["PLSwiftApp"]
        )
    ]
)
