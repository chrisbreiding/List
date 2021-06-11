import SwiftUI

@main
struct ListApp: App {
    @StateObject private var modelData = ModelData()
    @StateObject private var remoteData = RemoteData()

    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(modelData)
            .environmentObject(remoteData)
        }
    }
}
