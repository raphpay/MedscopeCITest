// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Medscope",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🌱 Fluent driver for Mongo.
        .package(url: "https://github.com/vapor/fluent-mongo-driver.git", from: "1.3.1"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 📖 OpenAPI Documentation
        .package(url: "https://github.com/dankinsoid/VaporToOpenAPI.git", from: "4.8.3"),
        // SendGrid emails
        .package(url: "https://github.com/vapor-community/sendgrid-kit.git", from: "2.0.0"),
        // Zip
        .package(url: "https://github.com/vapor-community/Zip.git", exact: "2.2.0"),
        // Queues
        .package(url: "https://github.com/vapor/queues.git", from: "1.0.0"),
        // SwiftLint
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.0")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "SendGridKit", package: "sendgrid-kit"),
                .product(name: "VaporToOpenAPI", package: "VaporToOpenAPI"),
                .product(name: "Zip", package: "Zip"),
                .product(name: "Queues", package: "queues"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
] }
