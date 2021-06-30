import Foundation
import Combine

final class ModelData: ObservableObject {
    @Published var categories: [Category] = []

    var hasStores: Bool {
        return categories.count > 0
    }

    func store(_ storeId: String) -> Store {
        let (categoryIndex, storeIndex) = getIndicesByStoreId(storeId)!

        return categories[categoryIndex].stores[storeIndex]
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

    func serializeItems(_ storeId: String) -> [Item.Serialized] {
        let (categoryIndex, storeIndex) = getIndicesByStoreId(storeId)!

        return categories[categoryIndex].stores[storeIndex].serializeItems()
    }

    func updateItem(_ storeId: String, _ item: Item) {
        let (categoryIndex, storeIndex) = getIndicesByStoreId(storeId)!

        let index = categories[categoryIndex].stores[storeIndex].items.firstIndex(where: { $0.id == item.id })

        if index == nil { return }

        categories[categoryIndex].stores[storeIndex].items[index!] = item
    }

    func moveItem(_ storeId: String, _ from: IndexSet, _ to: Int) {
        let (categoryIndex, storeIndex) = getIndicesByStoreId(storeId)!

        categories[categoryIndex].stores[storeIndex].items.move(fromOffsets: from, toOffset: to)

        print("items:")
        print(categories[categoryIndex].stores[storeIndex].items)
    }
    
    func deleteItem(_ storeId: String, _ item: Item) {
        let (categoryIndex, storeIndex) = getIndicesByStoreId(storeId)!

        let index = categories[categoryIndex].stores[storeIndex].items.firstIndex(where: { $0.id == item.id })

        if index == nil { return }

        categories[categoryIndex].stores[storeIndex].items.remove(at: index!)
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
