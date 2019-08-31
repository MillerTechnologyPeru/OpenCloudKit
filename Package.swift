// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "OpenCloudKit",
    products: [
        .library(
            name: "OpenCloudKit",
            targets: ["OpenCloudKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/clibressl.git", .branch("master")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "OpenCloudKit",
            dependencies: [
                "CLibreSSL",
                "CryptoSwift"
            ],
            path: "./Sources"
        ),
        .testTarget(
            name: "OpenCloudKitTests",
            dependencies: ["OpenCloudKit"]
        )
    ],
    swiftLanguageVersions: [.v5]
)

 
