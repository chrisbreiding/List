import SwiftUI

struct StoreList: View {
    @EnvironmentObject var remoteData: RemoteData
    @EnvironmentObject var modelData: ModelData
    @Environment(\.scenePhase) var scenePhase
    @State private var loading = true

    var body: some View {
        NavigationView {
            List {
                ForEach(modelData.categories) { category in
                    Section(header: Text(category.name)) {
                        ForEach(category.stores) { store in
                            let indices = modelData.getIndicesByStoreId(store.id)!
                            NavigationLink(destination: StoreDetail(
                                model: StoreDetailModel(
                                    store: store,
                                    categoryIndex: indices.categoryIndex,
                                    storeIndex: indices.storeIndex)
                            )) {
                                Text(store.name)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Stores")
    }
}

struct StoreList_Previews: PreviewProvider {
    static var previews: some View {
        StoreList()
        .environmentObject(RemoteData())
        .environmentObject(ModelData().loadPreviewData())
    }
}
