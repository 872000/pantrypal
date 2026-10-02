// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PantryPal",
    products: [
        .library(name: "PantryPal", targets: ["PantryPal"]),
    ],
    targets: [
        .target(
            name: "PantryPal",
            path: "Sources/PantryPal"
        ),
        .testTarget(
            name: "PantryPalTests",
            dependencies: ["PantryPal"],
            path: "Tests/PantryPalTests"
        ),
    ]
)
