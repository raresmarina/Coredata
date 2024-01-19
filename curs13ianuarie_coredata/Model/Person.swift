import Foundation

struct Person: Codable {
    var id: String = UUID().uuidString
    var name: String
    var age: Int
}
