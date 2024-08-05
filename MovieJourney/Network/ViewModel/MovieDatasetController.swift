import Foundation
import SwiftCSV
import UIKit

class MovieDatasetController {
    
    static var shared = MovieDatasetController()
    
    static var movies = [MovieModel]()

    static func parseDataset() {
        var movies: [MovieModel] = []
        
        guard let csv = try? CSV<Named>(
            name: "movieDataset",
            extension: "csv",
            bundle: .main,
            encoding: .utf8
        ) else { return }
        
        try? csv.enumerateAsDict { dict in
            let movie = MovieModel(
                id: Int(dict["id"] ?? "0") ?? 0,
                title: dict["title"] ?? ""
            )
            movies.append(movie)
        }
        
        self.movies = movies
    }
    
    func rateSession() -> [MovieUsableModel] {
        var selectedMovies = MovieDatasetController.movies.shuffled().prefix(3)
        var usableMovies = [MovieUsableModel]()
        let recommendationService = RecommendationService()
        
        let dispatchGroup = DispatchGroup()
        let imageQueue = DispatchQueue(label: "imageQueue")
        
        for movie in selectedMovies {
            dispatchGroup.enter()
            Task {
                if let usableMovie = await recommendationService.loadMoviePoster(for: movie.id!) {
                    imageQueue.sync {
                        usableMovies.append(usableMovie)
                    }
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
        return usableMovies
    }
    
    func randomMovie() async -> MovieUsableModel? {
        var movie = MovieDatasetController.movies.shuffled().randomElement()
        let recommendationService = RecommendationService()
    
        guard let usableMovie = await recommendationService.loadMoviePoster(for: movie?.id ?? 0) else { return nil }
        
        return usableMovie
    }
    
    func movieUsableModel(for id: Int) async -> MovieUsableModel? {
        let recommendationService = RecommendationService()
        guard let usableMovie = await recommendationService.loadMoviePoster(for: id) else { return nil }
        return usableMovie
    }
    
    func parseMovies<T: Decodable>(from json: String) -> T {
        guard let data = json.data(using: .utf8) else { return [] as! T }
        return try! JSONDecoder().decode(T.self, from: data)
    }
    
    func parseGenres(from json: String) -> [GenreModel] {
        return parseMovies(from: json)
    }
    
    func parseKeywords(from json: String) -> [KeywordModel] {
        return parseMovies(from: json)
    }
    
    func parseProductionCompanies(from json: String) -> [ProductionCompanyModel] {
        return parseMovies(from: json)
    }
    
    func parseProductionCountries(from json: String) -> [ProductionCountryModel] {
        return parseMovies(from: json)
    }
    
    func parseSpokenLanguages(from json: String) -> [SpokenLanguageModel] {
        return parseMovies(from: json)
    }
}
