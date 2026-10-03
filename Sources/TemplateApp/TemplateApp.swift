import Foundation
import SwiftUI
import TemplateAppCore

@main
struct TemplateApp: App {
    init() {
        // A command-line contract that Scripts/test-app.sh checks on the built bundle.
        if CommandLine.arguments.contains("--version") {
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "unknown"
            print(version)
            exit(0)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var name = ""

    var body: some View {
        VStack(spacing: 12) {
            Text(Greeting(name: name).text).font(.title)
            TextField("Your name", text: $name).textFieldStyle(.roundedBorder).frame(width: 240)
        }
        .padding(40)
    }
}
