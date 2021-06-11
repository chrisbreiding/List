import Foundation

struct Item: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var isChecked: Bool

    typealias Serialized = [String:Any]

    func serialize() -> Serialized {
        return [
            "id": id,
            "name": name,
            "isChecked": isChecked,
        ]
    }
}
