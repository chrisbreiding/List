import Foundation

struct Store: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var parentId: String
    var items: [Item] = []

    func serializeItems() -> [Item.Serialized] {
        return items.map { item in item.serialize() }
    }
}
