
 // swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ALMASIH",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "AlmasihCore",
            targets: ["AlmasihCore"]
        )
    ],
    targets: [
        .target(
            name: "AlmasihCore",
            path: "Sources/AlmasihCore"
        )
    ]
)
