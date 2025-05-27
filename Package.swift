// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CascableCoreGoPro",
    platforms: [.macOS(.v10_15), .iOS(.v13), .macCatalyst(.v15), .visionOS("1.1")],
    products: [.library(name: "CascableCoreGoPro", targets: ["CascableCoreGoPro"])],
    dependencies: [
        .package(name: "CascableCore", url: "https://github.com/Cascable/cascablecore-distribution", .upToNextMinor(from: "16.0.0-beta.1"))
    ], targets: [
        .binaryTarget(name: "CascableCoreGoPro", path: "CascableCoreGoPro.xcframework")
    ]
)
