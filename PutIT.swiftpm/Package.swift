// swift-tools-version: 5.9

// WARNING:
// This file is auto-generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "PutIT",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "PutIT",
            targets: ["AppModule"],
            bundleIdentifier: "com.nokeekoy.putit",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .box),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(purposeString: "Take photos of where your items are stored to create visual memory anchors."),
                .photoLibrary(purposeString: "Choose photos of your stored items from your photo library."),
                .speechRecognition(purposeString: "Use your voice to search for where your items are stored."),
                .microphone(purposeString: "Use your microphone for voice search.")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
