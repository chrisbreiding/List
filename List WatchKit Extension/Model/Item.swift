import Foundation

struct Item: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var isChecked: Bool
}
