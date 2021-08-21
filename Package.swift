// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUsedColors",
    platforms: [.macOS(.v10_12)],
    products: [
        .executable(name: "suc", targets: ["SwiftUsedColors"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.0"),
        .package(url: "https://github.com/Bouke/Glob.git", from: "1.0.4"),
        .package(url: "https://github.com/tuist/XcodeProj.git", from: "7.14.0"),
        .package(url: "https://github.com/IBDecodable/IBDecodable.git", from: "0.4.2"),
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "3.2.0"),
        .package(name: "CommandLineKit", url: "https://github.com/benoit-pereira-da-silva/CommandLine.git", from: "4.0.9"),
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax", from: "0.50300.0"),
        .package(url: "https://github.com/johngarrett/HyperSwift", .branch("master")),
    ],
    targets: [
        .target(
            name: "SwiftUsedColors",
            dependencies: ["HyperSwift","PathKit", "Glob", "XcodeProj", "IBDecodable", "CommandLineKit", "Rainbow", "SwiftSyntax"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
