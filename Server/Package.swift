// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "memes-server",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "memes-server",
                    targets: ["memes-server"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(name: "memes-server",
                dependencies: [
                    .product(name: "Vapor", package: "vapor")
                ]),
    ]
)
