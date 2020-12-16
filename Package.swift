// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "memes",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "memes-server",
                    targets: ["Server"]),
        .executable(name: "memes-client", targets: ["Client"]),
        .executable(name: "DeckApp", targets: ["DeckApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(name: "Tokamak", url: "https://github.com/TokamakUI/Tokamak", from: "0.6.0"),
    ],
    targets: [
        .target(name: "Server",
                dependencies: [
                    .product(name: "Vapor", package: "vapor"),
                    .target(name: "Model"),
                    .target(name: "Events"),
                    .target(name: "Deck")
                ]),
        .target(
            name: "Client",
            dependencies: [
                .product(name: "TokamakShim", package: "Tokamak"),
                .target(name: "Model"),
                .target(name: "Events"),
            ]),

        .target(
            name: "DeckApp",
            dependencies: [
                .target(name: "Model"),
                .target(name: "Deck"),
            ]),
        .target(name: "Events", dependencies: [.target(name: "Model")]),
        .target(name: "Deck", dependencies: [.target(name: "Model")]),
        .target(name: "Model"),
    ]
)
