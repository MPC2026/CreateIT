import Foundation

/// Loads and manages sample movie data from sample_List.json
class SampleListLoader: ObservableObject {
    @Published var loadedData: SampleListData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    static let shared = SampleListLoader()
    
    private init() {
        loadSampleData()
    }
    
    /// Load the sample list JSON file from the app bundle
    func loadSampleData() {
        isLoading = true
        
        guard let url = Bundle.main.url(forResource: "sample_List", withExtension: "json") else {
            errorMessage = "sample_List.json not found in bundle"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            loadedData = try decoder.decode(SampleListData.self, from: data)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to parse sample_List.json: \(error.localizedDescription)"
            print("Error loading sample list: \(error)")
        }
        
        isLoading = false
    }
    
    /// Get secondary genres for a primary genre
    func getSecondaryGenres(for primaryGenre: String) -> [String] {
        guard let data = loadedData else { return [] }
        
        if let genreData = data.genres.first(where: { $0.primary == primaryGenre }) {
            return genreData.secondaries.map { $0.secondary }
        }
        return []
    }
    
    /// Get sample movies for a primary-secondary genre combination
    func getSamples(for primaryGenre: String, secondaryGenre: String) -> [String] {
        guard let data = loadedData else { return [] }
        
        if let genreData = data.genres.first(where: { $0.primary == primaryGenre }),
           let secondaryData = genreData.secondaries.first(where: { $0.secondary == secondaryGenre }) {
            return secondaryData.samples
        }
        return []
    }
    
    /// Parse a sample movie string like "Bad Boys (1995)" into title and year
    static func parseMovieString(_ movieString: String) -> (title: String, year: Int)? {
        let pattern = "(.*)\\s\\((\\d{4})\\)$"
        guard let match = try? NSRegularExpression(pattern: pattern, options: []),
              let firstMatch = match.firstMatch(in: movieString, options: [], range: NSRange(movieString.startIndex..., in: movieString)),
              let titleRange = Range(firstMatch.range(at: 1), in: movieString),
              let yearRange = Range(firstMatch.range(at: 2), in: movieString) else {
            return nil
        }
        
        let title = String(movieString[titleRange]).trimmingCharacters(in: .whitespaces)
        guard let year = Int(movieString[yearRange]) else { return nil }
        
        return (title, year)
    }
}
