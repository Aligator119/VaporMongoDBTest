// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "VaporMongoDB",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/vapor/leaf-provider.git", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/vapor-community/mongo-provider.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/vapor/auth-provider.git", from: "1.1.0"),
//        .package(url: "https://github.com/vapor/auth.git", from: "1.2.1"),
//        .package(url: "https://github.com/vapor/crypto.git", from: "2.1.2"),
//        .package(url: "https://github.com/jernejstrasner/SwiftCrypto.git", from: "1.0.1")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentProvider", "LeafProvider", "MongoProvider", "AuthProvider"/*, "Crypto", "SwiftCrypto"*/],
                exclude: [
                    "Config",
                    "Public",
                    "Resources",
                    "Localization",
                ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "Testing"])
    ]
)
