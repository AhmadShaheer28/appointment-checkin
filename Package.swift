// swift-tools-version: 5.9
// Package.swift for CheckIn app

import PackageDescription

let package = Package(
    name: "CheckIn",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        // Google APIs for iOS
        .package(
            url: "https://github.com/google/google-api-objectivec-client-for-rest.git", 
            from: "3.0.0"
        ),
        // Google Sign-In
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS.git", 
            from: "7.0.0"
        )
    ],
    targets: [
        .target(
            name: "CheckIn",
            dependencies: [
                .product(name: "GoogleAPIClientForREST", package: "google-api-objectivec-client-for-rest"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ]
        )
    ]
) 