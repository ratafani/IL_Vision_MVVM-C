// swift-tools-version: 6.2
import PackageDescription

// ILVisionAssets
// Owner: Tech Artist + 3D Artists
//
// This package is the ONLY place where Reality Composer Pro content lives.
// Developers must NOT put Swift business logic here.
// Artists must NOT edit any other package.
//
// How to add 3D content:
//   1. Open RealityContent.rkassets in Reality Composer Pro.
//   2. Add/modify your scenes and entities.
//   3. Commit the .rkassets folder.
//   Devs will automatically get updated 3D content on the next build.

let package = Package(
    name: "ILVisionAssets",
    platforms: [.visionOS(.v26)],
    products: [
        .library(name: "ILVisionAssets", targets: ["ILVisionAssets"]),
    ],
    targets: [
        .target(
            name: "ILVisionAssets",
            path: "Sources/ILVisionAssets",
            resources: [
                .process("../../RealityContent.rkassets")
            ]
        ),
    ]
)
