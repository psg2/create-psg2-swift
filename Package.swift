// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TemplateApp",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "TemplateApp", targets: ["TemplateApp"])],
    targets: [
        .target(
            name: "TemplateAppCore",
            swiftSettings: [.unsafeFlags(["-warnings-as-errors"])]
        ),
        .executableTarget(
            name: "TemplateApp",
            dependencies: ["TemplateAppCore"],
            swiftSettings: [.unsafeFlags(["-warnings-as-errors"])]
        ),
        .testTarget(
            name: "TemplateAppCoreTests",
            dependencies: ["TemplateAppCore"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
