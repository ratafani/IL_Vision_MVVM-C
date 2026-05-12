// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ILVisionUI",
    platforms: [.visionOS(.v26)],
    products: [
        .library(name: "ILVisionUI", targets: ["ILVisionUI"]),
    ],
    dependencies: [
        .package(path: "../ILVisionDomain"),
        .package(path: "../ILVisionCore"),
        .package(path: "../ILVisionSimulation"),
        .package(path: "../ILVisionData"),
        .package(path: "../ILVisionHandTracking"),
        .package(path: "../ILVisionAssets")
    ],
    targets: [
        .target(
            name: "ILVisionUI",
            dependencies: [
                "ILVisionDomain",
                "ILVisionCore",
                "ILVisionSimulation",
                "ILVisionData",
                "ILVisionHandTracking",
                "ILVisionAssets"
            ]
        ),
    ]
)
