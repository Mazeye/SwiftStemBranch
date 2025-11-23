// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "GanZhi",
    products: [
        .library(
            name: "GanZhi",
            targets: ["GanZhi"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GanZhi",
            dependencies: []),
        .testTarget(
            name: "GanZhiTests",
            dependencies: ["GanZhi"]),
    ]
)

