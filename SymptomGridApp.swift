import SwiftUI

@main
struct SymptomGridApp: App {
    @StateObject private var store = LogStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
