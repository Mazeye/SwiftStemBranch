// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "GanZhi",
    products: [
        .library(
            name: "GanZhi",
            targets: ["GanZhi"]),
        .executable(
            name: "Sample",
            targets: ["Sample"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GanZhi",
            dependencies: []),
        .executableTarget(
            name: "Sample",
            dependencies: ["GanZhi"]),
        .testTarget(
            name: "GanZhiTests",
            dependencies: ["GanZhi"]),
    ]
)
