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
                    remoteData.connect()
                })
            } else {
                ProgressView("Connecting")
            }
        }
        .onAppear {
            print("ContentView onAppear - connect")
            remoteData.modelData = modelData
            remoteData.connect()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(RemoteData())
            .environmentObject(ModelData().loadPreviewData())
    }
}
