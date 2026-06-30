import Foundation

/// Data model for parsing sample_List.json
struct SampleListData: Codable {
    let genres: [GenreData]
}

struct GenreData: Codable, Equatable {
    let primary: String
    let secondaries: [SecondaryGenreData]
}

struct SecondaryGenreData: Codable, Equatable {
    let secondary: String
    let samples: [String]  // Format: "Movie Title (Year)"
}
