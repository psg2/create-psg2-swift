import Foundation

/// Replace this with the app's real domain logic. Keep it free of SwiftUI so
/// `swift test` covers it without launching the app.
public struct Greeting: Equatable, Sendable {
    public let name: String

    public init(name: String) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var text: String {
        name.isEmpty ? "Hello!" : "Hello, \(name)!"
    }
}
