// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChromaControl",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ChromaControl", targets: ["ChromaControl"])
    ],
    targets: [
        .target(
            name: "CRazerDriver",
            path: "Sources/CRazerDriver",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include")
            ],
            linkerSettings: [
                .linkedFramework("IOKit"),
                .linkedFramework("CoreFoundation")
            ]
        ),
        .executableTarget(
            name: "ChromaControl",
            dependencies: ["CRazerDriver"],
            path: "Sources/ChromaControl"
        )
    ]
)
