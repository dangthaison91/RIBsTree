// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "RIBsTree",
    platforms: [.iOS(.v8)],
    products: [
        .library(name: "RIBsTree", targets: ["RIBsTree"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.1.0"),
        .package(url: "https://github.com/dangthaison91/RIBs.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "RIBsTree",
            dependencies: ["RxSwift", "RxCocoa", "RIBs"],
            path: "./RIBsTree/Sources"
        )
    ]
)
