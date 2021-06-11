import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var remoteData: RemoteData
    @Environment(\.scenePhase) var scenePhase
    @State private var error: Error? = nil
    @State private var started = false

    var body: some View {
        Group {
            if remoteData.hasError(.connection) {
                ErrorView(error: remoteData.error!, onRetry: {
                    print("Retry after error - connect")
                    connectAndGetStores()
                })
            } else if remoteData.hasError(.stores) {
                ErrorView(error: remoteData.error!, onRetry: {
                    print("Retry after error - get stores")
                    getStores()
                })
            } else if modelData.hasStores {
                StoreList()
            } else {
                ProgressView("Loading")
            }
        }
        .onAppear {
            print("ContentView onAppear")
            start()
        }
        .onChange(of: scenePhase) { scenePhase in
            print("scenePhase: \(scenePhase)")
            switch scenePhase {
                case .active:
                    remoteData.connect(remoteData.onReconnect)
                case .inactive:
                    remoteData.disconnect()
                case .background:
                    break
                @unknown default:
                    break
            }
        }
    }

    func start() {
        if started { return }

        started = true

        print("ContentView - start")
        remoteData.modelData = modelData
        remoteData.subscribeToItems()
        connectAndGetStores()
    }

    func connectAndGetStores() {
        remoteData.connect(getStores)
    }

    func getStores() {
        print("ContentView - get stores")
        remoteData.getStores()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(RemoteData())
            .environmentObject(ModelData().loadPreviewData())
    }
}
