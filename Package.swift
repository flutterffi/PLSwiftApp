// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "PLSwiftApp",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
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
