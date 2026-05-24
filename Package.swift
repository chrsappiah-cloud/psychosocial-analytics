// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PsychosocialAnalytics",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PsychosocialAnalytics",
            targets: ["PsychosocialAnalytics"]),
    ],
    targets: [
        .target(
            name: "PsychosocialAnalytics",
            dependencies: [],
            path: "Sources/PsychosocialAnalytics"),
        .testTarget(
            name: "PsychosocialAnalyticsTests",
            dependencies: ["PsychosocialAnalytics"],
            path: "Tests/PsychosocialAnalyticsTests"),
    ]
)
