import Foundation

struct Error: Hashable, Codable {
    let name: String
    let message: String
    let stack: String

    var reason: Reason
    enum Reason: String, CaseIterable, Codable {
        case connection = "connection"
        case stores = "stores"
        case items = "items"
        case other = "other"
    }
}
