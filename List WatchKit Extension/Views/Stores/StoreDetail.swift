import SwiftUI

struct StoreDetail: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var remoteData: RemoteData
    @State private var loading = true
    @State private var showUncheckedOnly = UserDefaults.standard.bool(forKey: "Items.ShowUncheckedOnly")
    @State private var error: Error? = nil
    let model: StoreDetailModel

    var body: some View {
        Group {
            if loading {
                // switching directly from the List to a ProgressView causes an error
                // for some reason, but wrapping it in a ScrollView does not error
                ScrollView {
                    VStack(alignment: .center) {
                        Text(" ").frame(width: 100.0, height: 50.0)
                        ProgressView()
                        Text(" ").frame(width: 100.0, height: 50.0)
                        Text("Loading items")
                    }
                }
                .disabled(true)
            } else if remoteData.hasError(.items) {
                ErrorView(error: remoteData.error!)
            } else {
                ItemList(
                    showUncheckedOnly: $showUncheckedOnly,
                    storeDetailModel: model,
                    syncItems: syncItems,
                    onUpdateItem: updateItem
                )
            }
        }
        .navigationTitle("Stores")
        .onAppear {
            print("StoreDetail onAppear - subscribe")
            subscribe()
        }
        .onDisappear {
            print("StoreDetail onDisappear - unsubscribe")
            unsubscribe()
        }
    }

    func subscribe() {
        loading = true

        remoteData.subscribeToItems(model) {
            loading = false
        }
    }

    func unsubscribe() {
        remoteData.unsubscribeToItems(model)
    }

    func updateItem(_ item: Item)  {
        if loading { return }

        remoteData.updateItem(model, item)
    }

    func syncItems() {
        print("sync items")
        if loading { return }

        loading = true

        remoteData.syncItems(model)
    }
}

struct StoreDetail_Previews: PreviewProvider {
    static var previews: some View {
        let previewData = ModelData().loadPreviewData()

        StoreDetail(
            model: StoreDetailModel(
                store: previewData.categories[0].stores[0],
                categoryIndex: 0,
                storeIndex: 0
            )
        )
        .environmentObject(previewData)
    }
}
