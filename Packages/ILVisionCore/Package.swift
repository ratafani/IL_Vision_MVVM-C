// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ILVisionCore",
    platforms: [.visionOS(.v26)],
    products: [
        .library(name: "ILVisionCore", targets: ["ILVisionCore"]),
    ],
    dependencies: [
        .package(path: "../ILVisionDomain"),
        .package(path: "../ILVisionData"),
    ],
    targets: [
        .target(
            name: "ILVisionCore",
            dependencies: [
                "ILVisionDomain",
                "ILVisionData"
            ]
        ),
    ]
)
