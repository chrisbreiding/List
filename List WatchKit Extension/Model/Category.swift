import Foundation

struct Category: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var stores: [Store] = []
}

