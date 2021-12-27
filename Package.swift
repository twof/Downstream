// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "downstream",
    products: [
      .executable(name: "downstream", targets: ["downstream"])
    ],
    dependencies: [
      .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),
      .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
      .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.2"), 
    ],
    targets: [
        .executableTarget(
            name: "downstream",
            dependencies: [
              .product(name: "Yams", package: "Yams"),
              .product(name: "Files", package: "Files"),
              .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            exclude: [
              "downstream.yml"
            ]
        ),
        .testTarget(
            name: "DownstreamTests",
            dependencies: [
              .target(name: "downstream")
            ]
        ),
    ]
)
