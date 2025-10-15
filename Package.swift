// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CascableCoreGoPro",
    platforms: [.macOS(.v11), .iOS(.v14), .macCatalyst(.v15), .visionOS("1.1")],
    products: [.library(name: "CascableCoreGoPro", targets: ["CascableCoreGoPro"])],
    dependencies: [
        .package(url: "https://github.com/Cascable/cascablecore-distribution", from: "16.0.1")
    ], targets: [
        .binaryTarget(name: "CascableCoreGoPro", path: "CascableCoreGoPro.xcframework")
    ]
)
