import Foundation
import Combine

final class ModelData: ObservableObject {
    @Published var categories: [Category] = []
    var categoryIndex: Int? = nil
    var storeIndex: Int? = nil

    var hasStores: Bool {
        return categories.count > 0
    }

    func store(_ storeDetailModel: StoreDetailModel) -> Store {
        return categories[storeDetailModel.categoryIndex].stores[storeDetailModel.storeIndex]
    }

    func getIndicesByStoreId(_ storeId: String) -> (Int, Int)? {
        for (categoryIndex, category) in categories.enumerated() {
            for (storeIndex, store) in category.stores.enumerated() {
                if store.id == storeId {
                    return (categoryIndex, storeIndex)
                }
            }
        }

        return nil
    }

    func serializeItems(_ storeDetailModel: StoreDetailModel) -> [Item.Serialized] {
        let catIndex = storeDetailModel.categoryIndex
        let storeIndex = storeDetailModel.storeIndex

        return categories[catIndex].stores[storeIndex].serializeItems()
    }

    func updateItem(_ storeDetailModel: StoreDetailModel, _ item: Item) {
        let catIndex = storeDetailModel.categoryIndex
        let storeIndex = storeDetailModel.storeIndex

        let index = categories[catIndex].stores[storeIndex].items.firstIndex(where: { $0.id == item.id })

        if index == nil { return }

        categories[catIndex].stores[storeIndex].items[index!] = item
    }

    func moveItem(_ storeDetailModel: StoreDetailModel, _ from: IndexSet, _ to: Int) {
        let catIndex = storeDetailModel.categoryIndex
        let storeIndex = storeDetailModel.storeIndex

        categories[catIndex].stores[storeIndex].items.move(fromOffsets: from, toOffset: to)

        print("items:")
        print(categories[catIndex].stores[storeIndex].items)
    }
    
    func deleteItem(_ storeDetailModel: StoreDetailModel, _ item: Item) {
        let catIndex = storeDetailModel.categoryIndex
        let storeIndex = storeDetailModel.storeIndex

        let index = categories[catIndex].stores[storeIndex].items.firstIndex(where: { $0.id == item.id })

        if index == nil { return }

        categories[catIndex].stores[storeIndex].items.remove(at: index!)
    }

    func loadPreviewData() -> ModelData {
        print("loadPreviewData")

        categories = PreviewData.get()
        
        return self
    }

    func load<T: Decodable>(_ filename: String) -> T {
        let data: Data

        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }

        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle\n\(error)")
        }
        
        print("data:")
        print(data)

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
}
