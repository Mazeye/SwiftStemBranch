// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "GanZhi",
    products: [
        .library(
            name: "GanZhi",
            targets: ["GanZhi"]),
        .library(
            name: "GanZhiWasmBridge",
            targets: ["GanZhiWasmBridge"]),
        .executable(
            name: "Sample",
            targets: ["Sample"]),
        .executable(
            name: "BaziDistribution",
            targets: ["BaziDistribution"]),
        .executable(
            name: "GanZhiWasmRuntime",
            targets: ["GanZhiWasmRuntime"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GanZhi",
            dependencies: []),
        .target(
            name: "GanZhiWasmBridge",
            dependencies: ["GanZhi"]),
        .executableTarget(
            name: "Sample",
            dependencies: ["GanZhi"]),
        .executableTarget(
            name: "BaziDistribution",
            dependencies: ["GanZhi"]),
        .executableTarget(
            name: "GanZhiWasmRuntime",
            dependencies: ["GanZhiWasmBridge"]),
        .testTarget(
            name: "GanZhiTests",
            dependencies: ["GanZhi"]),
    ]
)
