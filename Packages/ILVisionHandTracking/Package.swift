// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ILVisionHandTracking",
    platforms: [.visionOS(.v26)],
    products: [
        .library(name: "ILVisionHandTracking", targets: ["ILVisionHandTracking"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ILVisionHandTracking",
            dependencies: []
        ),
    ]
)
