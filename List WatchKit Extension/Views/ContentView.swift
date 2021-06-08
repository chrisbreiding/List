import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var remoteData: RemoteData
    @Environment(\.scenePhase) var scenePhase
    @State private var error: Error? = nil

    var body: some View {
        Group {
            if modelData.hasStores || remoteData.connected {
                StoreList()
            } else if remoteData.hasError(.connection) {
                ErrorView(error: remoteData.error!, onRetry: {
                    print("Retry after error - connect")
                    connect()
                })
            } else if remoteData.hasError(.stores) {
                ErrorView(error: remoteData.error!, onRetry: {
                    print("Retry after error - get stores")
                    getStores()
                })
            } else {
                ProgressView("Loading")
            }
        }
        .onAppear {
            print("ContentView onAppear - connect")
            start()
        }
    }

    func start() {
        remoteData.modelData = modelData
        remoteData.subscribeToItems()
        connect()
    }

    func connect() {
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
