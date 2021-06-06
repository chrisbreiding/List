import SwiftUI

struct StoreList: View {
    @EnvironmentObject var remoteData: RemoteData
    @EnvironmentObject var modelData: ModelData
    @Environment(\.scenePhase) var scenePhase
    @State private var loading = true

    var body: some View {
        NavigationView {
            if loading {
                ProgressView("Loading stores")
            } else if remoteData.hasError(.stores) {
                ErrorView(error: remoteData.error!, onRetry: {
                    print("Retry after error - get stores")
                    getStores()
                })
            } else {
                List {
                    ForEach(modelData.categories.indices) { i in
                        let category = modelData.categories[i]
                        Section(header: Text(category.name)) {
                            ForEach(category.stores.indices) { j in
                                let store = category.stores[j]
                                NavigationLink(destination: StoreDetail(
                                    model: StoreDetailModel(store: store, categoryIndex: i, storeIndex: j)
                                )) {
                                    Text(store.name)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Stores")
        .onAppear {
            print("StoreList onAppear - get stores")
            getStores()
        }
    }

    func getStores() {
        remoteData.getStores {
            DispatchQueue.main.async {
                loading = false
            }
        }
    }
}

struct StoreList_Previews: PreviewProvider {
    static var previews: some View {
        StoreList()
        .environmentObject(RemoteData())
        .environmentObject(ModelData().loadPreviewData())
    }
}
