import Foundation

struct Store: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var parentId: String
    var items: [Item] = []
}
