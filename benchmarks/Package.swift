// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "benchmarks",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(name: "swift-memcache-gsoc", path: "../"),
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.56.0"),

    ],
    targets: [
        .executableTarget(
            name: "SwiftMemcacheBenchmarks",
            dependencies: [
                "Sources",
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOEmbedded", package: "swift-nio"),
            ],
            path: "Benchmarks/SwiftMemcacheBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),
        .target(
            name: "Sources",
            dependencies: [
                .product(name: "SwiftMemcache", package: "swift-memcache-gsoc"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "Tests",
            dependencies: [
                "Sources",
            ],
            path: "Tests"
        ),
    ]
)
