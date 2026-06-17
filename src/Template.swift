import Foundation

struct Template: Identifiable, Codable {
    let id = UUID()
    var name: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, content: String) {
        self.name = name
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}