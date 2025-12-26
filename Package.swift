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
        .executable(
            name: "BaziDistribution",
            targets: ["BaziDistribution"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GanZhi",
            dependencies: []),
        .executableTarget(
            name: "Sample",
            dependencies: ["GanZhi"]),
        .executableTarget(
            name: "BaziDistribution",
            dependencies: ["GanZhi"]),
        .testTarget(
            name: "GanZhiTests",
            dependencies: ["GanZhi"]),
    ]
)
