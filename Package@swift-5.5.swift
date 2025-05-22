// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CascableCoreGoPro",
    platforms: [.macOS(.v11), .iOS(.v14), .macCatalyst(.v15)],
    products: [.library(name: "CascableCoreGoPro", targets: ["CascableCoreGoPro"])],
    dependencies: [
        .package(name: "CascableCore", url: "https://github.com/Cascable/cascablecore-distribution", .upToNextMajor(from: "16.0.0"))
    ], targets: [
        .binaryTarget(name: "CascableCoreGoPro", path: "CascableCoreGoPro.xcframework")
    ]
)
