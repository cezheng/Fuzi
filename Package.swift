// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Starting with Xcode 12, we don't need to depend on our own libxml2 target
#if swift(>=5.3) && !os(Linux)
let dependencies: [Target.Dependency] = []
#else
let dependencies: [Target.Dependency] = ["libxml2"]
#endif

#if swift(>=5.2) && !os(Linux)
let pkgConfig: String? = nil
#else
let pkgConfig = "libxml-2.0"
#endif

#if swift(>=5.2)
let provider: [SystemPackageProvider] = [
    .apt(["libxml2-dev"])
]
#else
let provider: [SystemPackageProvider] = [
    .apt(["libxml2-dev"]),
    .brew(["libxml2"])
]
#endif

let package = Package(
  name: "Fuzi",
  products: [
    .library(name: "Fuzi", targets: ["Fuzi"]),
  ],
  targets: [
    .systemLibrary(
      name: "libxml2",
      path: "Modules",
      pkgConfig: pkgConfig,
      providers: provider),
    .target(
      name: "Fuzi",
      dependencies: dependencies,
      path: "Sources"),
    .testTarget(
      name: "FuziTests",
      dependencies: ["Fuzi"],
      path: "Tests")
  ]
)
