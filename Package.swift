// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PLSwiftApp",
    defaultLocalization: "en",
    platforms: [
        .iOS("18.0"),
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PLSwiftApp", targets: ["PLSwiftApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2")
    ],
    targets: [
        .executableTarget(
            name: "PLSwiftApp",
            dependencies: [],
            resources: [
                .process("Resources")
            ],
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]
        ),
        .testTarget(
            name: "PLSwiftAppTests",
            dependencies: ["PLSwiftApp"]
        )
    ]
)
