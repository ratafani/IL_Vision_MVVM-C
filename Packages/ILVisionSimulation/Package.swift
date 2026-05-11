// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ILVisionSimulation",
    platforms: [.visionOS(.v26)],
    products: [
        .library(name: "ILVisionSimulation", targets: ["ILVisionSimulation"]),
    ],
    dependencies: [
        .package(path: "../ILVisionDomain"),
        .package(path: "../ILVisionCore"),
        .package(path: "../ILVisionHandTracking")
    ],
    targets: [
        .target(
            name: "ILVisionSimulation",
            dependencies: [
                "ILVisionDomain",
                "ILVisionCore",
                "ILVisionHandTracking"
            ]
        ),
    ]
)
