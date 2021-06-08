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

    struct Indices {
        let categoryIndex: Int
        let storeIndex: Int
    }

    func getIndicesByStoreId(_ storeId: String) -> Indices? {
        for (categoryIndex, category) in categories.enumerated() {
            for (storeIndex, store) in category.stores.enumerated() {
                if store.id == storeId {
                    return Indices(categoryIndex: categoryIndex, storeIndex: storeIndex)
                }
            }
        }

        return nil
    }

//    func addItem(_ )

    func updateItem(_ storeDetailModel: StoreDetailModel, _ item: Item) {
        let catIndex = storeDetailModel.categoryIndex
        let storeIndex = storeDetailModel.storeIndex

        let index = categories[catIndex].stores[storeIndex].items.firstIndex(where: { $0.id == item.id })

        if index == nil { return }

        categories[catIndex].stores[storeIndex].items[index!] = item
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
