import SwiftUI

// App entry point. The `@main` attribute is intentionally omitted here so this
// file can be compiled as part of a library target alongside unit tests
// without triggering a duplicate `_main` symbol at link time.
//
// When integrating into an iOS Xcode project, add a thin wrapper executable
// target (or annotate this type with `@main` in an app target) that simply
// imports PsychosocialAnalytics and presents `RootShellView()`.
public struct PsychosocialAnalyticsApp: App {
    public init() {}
    public var body: some Scene {
        WindowGroup {
            RootShellView()
        }
    }
}
