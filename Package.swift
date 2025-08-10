// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SpeechTranscriber",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SpeechTranscriber", targets: ["SpeechTranscriber"])
    ],
    targets: [
        .executableTarget(
            name: "SpeechTranscriber"
        )
    ]
)
