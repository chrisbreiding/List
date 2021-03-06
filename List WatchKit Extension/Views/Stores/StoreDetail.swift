import SwiftUI

struct StoreDetail: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var remoteData: RemoteData
    @State private var syncing = false
    @State private var showUncheckedOnly = UserDefaults.standard.bool(forKey: "Items.ShowUncheckedOnly")
    @State private var error: Error? = nil
    let store: Store

    var body: some View {
        Group {
            if syncing {
                // switching directly from the List to a ProgressView causes an error
                // for some reason, but wrapping it in a ScrollView does not error
                ScrollView {
                    VStack(alignment: .center) {
                        Text(" ").frame(width: 100.0, height: 50.0)
                        ProgressView()
                        Text(" ").frame(width: 100.0, height: 50.0)
                        Text("Syncing items")
                    }
                }
                .disabled(true)
            } else if remoteData.hasError(.items) {
                ErrorView(error: remoteData.error!)
            } else {
                ItemList(
                    showUncheckedOnly: $showUncheckedOnly,
                    store: store,
                    syncItems: syncItems,
                    onUpdateItem: updateItem,
                    onDeleteItem: deleteItem
                )
            }
        }
        .navigationTitle("Stores")
    }

    func updateItem(_ item: Item)  {
        if syncing { return }

        remoteData.updateItem(store, item)
    }

    func deleteItem(_ item: Item) {
        if syncing { return }

        remoteData.deleteItem(store, item)
    }

    func syncItems() {
        print("sync items")
        if syncing { return }

        syncing = true

        remoteData.syncItems(store) {
            DispatchQueue.main.async {
                syncing = false
            }
        }
    }
}

struct StoreDetail_Previews: PreviewProvider {
    static var previews: some View {
        let previewData = ModelData().loadPreviewData()

        StoreDetail(store: previewData.categories[0].stores[0])
        .environmentObject(previewData)
        .environmentObject(RemoteData())
    }
}
