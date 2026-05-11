// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ILVisionDomain",
    platforms: [.visionOS(.v26)],
    products: [
        .library(name: "ILVisionDomain", targets: ["ILVisionDomain"]),
    ],
    targets: [
        .target(name: "ILVisionDomain"),
    ]
)
