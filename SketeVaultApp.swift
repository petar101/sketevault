import SwiftUI

@main
struct SketeVaultApp: App {
    @StateObject private var library = MediaLibrary()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(library)
        }
    }
}
