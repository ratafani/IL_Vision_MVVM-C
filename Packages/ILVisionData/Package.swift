// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ILVisionData",
    platforms: [.visionOS(.v26)],
    products: [
        .library(name: "ILVisionData", targets: ["ILVisionData"]),
    ],
    dependencies: [
        .package(path: "../ILVisionDomain"),
    ],
    targets: [
        .target(
            name: "ILVisionData",
            dependencies: ["ILVisionDomain"]
        ),
    ]
)
