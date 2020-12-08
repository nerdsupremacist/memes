// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "memes-client",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "memes-client", targets: ["memes-client"])
    ],
    dependencies: [
        .package(name: "Tokamak", url: "https://github.com/TokamakUI/Tokamak", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "memes-client",
            dependencies: [
                .product(name: "TokamakShim", package: "Tokamak")
            ]),
    ]
)
