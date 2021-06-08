import SwiftUI

struct ItemList: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var remoteData: RemoteData
    @Binding var showUncheckedOnly: Bool
    let storeDetailModel: StoreDetailModel
    let syncItems: () -> Void
    let onUpdateItem: (Item) -> Void
    let onDeleteItem: (Item) -> Void

    var filteredItems: [Item] {
        modelData.store(storeDetailModel).items.filter { item in
            (!showUncheckedOnly || !item.isChecked)
        }
    }

    var body: some View {
        List {
            Section(header: Text(storeDetailModel.store.name)) {
                Toggle(isOn: $showUncheckedOnly) {
                    Text("Hide checked")
                }

                ForEach(filteredItems) { item in
                    ItemRow(
                        item: item,
                        onUpdate: onUpdateItem
                    )
                }
                .onDelete(perform: onDelete)

                if filteredItems.count == 0 {
                    Text("No items").listRowBackground(Color.black)
                }

                Button(action: addItem) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus")
                        Text("Add Item")
                        Spacer()
                    }
                }
                .foregroundColor(.green)
            }

            Section(header: Spacer()) {
                Button(action: syncItems) {
                    HStack(spacing: 5) {
                        Spacer()
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Sync Items")
                        Spacer()
                    }
                }
                .foregroundColor(Color.blue)
            }
        }
        .onChange(of: showUncheckedOnly) { value in
            UserDefaults.standard.set(value, forKey: "Items.ShowUncheckedOnly")
        }
    }

    func addItem() {
        remoteData.addItem(storeDetailModel)
    }

    func onDelete(at offsets: IndexSet) {
        if offsets.first != nil {
            let item = filteredItems[offsets.first!]
            onDeleteItem(item)
        }
    }
}

struct ItemList_Previews: PreviewProvider {
    static var previews: some View {
        let previewData = ModelData().loadPreviewData()

        ItemList(
            showUncheckedOnly: .constant(false),
            storeDetailModel: StoreDetailModel(
                store: previewData.categories[0].stores[0],
                categoryIndex: 0,
                storeIndex: 0
            ),
            syncItems: {},
            onUpdateItem: { item in },
            onDeleteItem: { offsets in }
        )
        .environmentObject(previewData)
    }
}
