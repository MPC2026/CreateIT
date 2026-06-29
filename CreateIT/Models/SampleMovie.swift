import Foundation

/// A reference film used as a stylistic sample. Its `beatSamples` map
/// beat keys (from `BeatLibrary`) to short, illustrative descriptions.
/// These are original paraphrased summaries meant as structural guidance —
/// never to be copied into the writer's own script.
struct SampleMovie: Identifiable, Codable {
    let id = UUID()
    let title: String
    let year: Int
    let genre: Genre
    let logline: String
    let beatSamples: [String: String]

    /// Returns the sample text for a beat key, if one exists.
    func sample(for key: String) -> String? { beatSamples[key] }
}
