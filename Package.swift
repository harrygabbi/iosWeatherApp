// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v13) // Adjust depending on your target version
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/open-meteo/sdk.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "MyApp",
            dependencies: [
                .product(name: "OpenMeteoSdk", package: "sdk")
            ])
    ]
)
