import Foundation

struct SceneOutlineScene: Identifiable, Codable, Equatable {
    var id: UUID
    var act: Int
    var beatKey: String?
    var beatSceneNumber: Int
    var title: String
    var summary: String

    init(
        id: UUID = UUID(),
        act: Int,
        beatKey: String? = nil,
        beatSceneNumber: Int = 1,
        title: String,
        summary: String
    ) {
        self.id = id
        self.act = act
        self.beatKey = beatKey
        self.beatSceneNumber = beatSceneNumber
        self.title = title
        self.summary = summary
    }

    enum CodingKeys: String, CodingKey {
        case id, act, beatKey, beatSceneNumber, title, summary
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        act = try container.decode(Int.self, forKey: .act)
        beatKey = try container.decodeIfPresent(String.self, forKey: .beatKey)
        beatSceneNumber = try container.decodeIfPresent(Int.self, forKey: .beatSceneNumber) ?? 1
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(act, forKey: .act)
        try container.encodeIfPresent(beatKey, forKey: .beatKey)
        try container.encode(beatSceneNumber, forKey: .beatSceneNumber)
        try container.encode(title, forKey: .title)
        try container.encode(summary, forKey: .summary)
    }
}
