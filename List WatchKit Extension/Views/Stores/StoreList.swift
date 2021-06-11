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
                ForEach(modelData.categories) { category in
                    Section(header: sectionHeader(category)) {
                        ForEach(category.stores) { store in
                            let (categoryIndex, storeIndex) = modelData.getIndicesByStoreId(store.id)!
                            NavigationLink(destination: StoreDetail(
                                model: StoreDetailModel(
                                    store: store,
                                    categoryIndex: categoryIndex,
                                    storeIndex: storeIndex)
                            )) {
                                Text(store.name)
                            }
                        }
                    }
                }
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
}

struct StoreList_Previews: PreviewProvider {
    static var previews: some View {
        StoreList()
        .environmentObject(RemoteData())
        .environmentObject(ModelData().loadPreviewData())
    }
}
