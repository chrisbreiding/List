import SwiftUI

struct StoreList: View {
    @EnvironmentObject var remoteData: RemoteData
    @EnvironmentObject var modelData: ModelData
    @Environment(\.scenePhase) var scenePhase

    func sectionHeader(_ category: Category) -> some View {
        HStack {
            Text(category.name)
            if remoteData.debug && category.name == "Grocery" {
                Spacer()
                Indicator(status: remoteData.status)
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(modelData.categories, id: \.id) { category in
                    Section(header: sectionHeader(category)) {
                        ForEach(category.stores, id: \.id) { store in
                            NavigationLink(destination: StoreDetail(store: store)) {
                                Text(store.name)
                            }
                        }
                    }
                }

                Button(action: syncStores) {
                    HStack(spacing: 5) {
                        Spacer()
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Sync Stores")
                        Spacer()
                    }
                }
                .foregroundColor(Color.blue)

                Spacer()
                .listRowBackground(Color.black)

                Toggle(isOn: $remoteData.debug) {
                    Text("Debug")
                }
                if remoteData.debug {
                    Button(remoteData.status == .notConnected ? "Connect" : "Disconnect") {
                        switch remoteData.status {
                            case .connected, .connecting:
                                remoteData.disconnect()
                            case .notConnected:
                                remoteData.connect()
                        }
                    }
                }
            }
        }
        .onAppear {
            if remoteData.debug {
                remoteData.trackStatus()
            }
        }
        .onChange(of: remoteData.debug, perform: { debug in
            UserDefaults.standard.set(debug, forKey: "Debug")

            if debug {
                remoteData.trackStatus()
            } else {
                remoteData.stopTrackingStatus()
            }
        })
    }

    func syncStores() {
        remoteData.getStores()
    }
}

struct StoreList_Previews: PreviewProvider {
    static var previews: some View {
        StoreList()
        .environmentObject(RemoteData().enableDebug())
        .environmentObject(ModelData().loadPreviewData())
    }
}
