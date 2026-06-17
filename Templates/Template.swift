import Foundation

struct Template: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var lastEdited: Date
    var state: String // For restore point storage
    
    init(id: UUID = UUID(), name: String, description: String = "", lastEdited: Date = Date(), state: String = "") {
        self.id = id
        self.name = name
        self.description = description
        self.lastEdited = lastEdited
        self.state = state
    }
}

struct RestorePoint: Identifiable, Codable {
    let id: UUID
    var timestamp: Date
    var templateState: String
    
    init(id: UUID = UUID(), timestamp: Date = Date(), templateState: String) {
        self.id = id
        self.timestamp = timestamp
        self.templateState = templateState
    }
}