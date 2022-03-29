// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SwiftlySalesforce",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "SwiftlySalesforce",
            targets: ["SwiftlySalesforce"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftlySalesforce",
            dependencies: []),
        .testTarget(
            name: "SwiftlySalesforceTests",
            dependencies: ["SwiftlySalesforce"],
            resources: [
                .copy("MockAccount.json"),
                .copy("MockAccountMetadata.json"),
                .copy("MockAccountMissingURLAttribute.json"),
                .copy("MockAggregateQueryResult.json"),
                .copy("MockConfig.json"),
                .copy("MockIdentity.json"),
                .copy("MockLimits.json"),
                .copy("MockSearchResults.json")
            ]
        ),
    ]
)
