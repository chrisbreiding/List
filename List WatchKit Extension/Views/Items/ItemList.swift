import SwiftUI

struct ItemList: View {
    @EnvironmentObject var modelData: ModelData
    @Binding var showUncheckedOnly: Bool
    let storeDetailModel: StoreDetailModel
    let syncItems: () -> Void
    let onUpdateItem: (Item) -> Void

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

                if filteredItems.count == 0 {
                    Text("No items").listRowBackground(Color.black)
                }
            }

            Section(header: Spacer()) {
                Button(action: syncItems) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Sync Items")
                    }
                }
                .foregroundColor(Color.blue)
            }
        }
        .onChange(of: showUncheckedOnly) { value in
            UserDefaults.standard.set(value, forKey: "Items.ShowUncheckedOnly")
        }
    }
}

struct ItemList_Previews: PreviewProvider {
    static var previews: some View {
        let previewData = ModelData().loadPreviewData()

        ItemList(
            showUncheckedOnly: .constant(true),
            storeDetailModel: StoreDetailModel(
                store: previewData.categories[0].stores[0],
                categoryIndex: 0,
                storeIndex: 0
            ),
            syncItems: {},
            onUpdateItem: { item in }
        )
    }
}
