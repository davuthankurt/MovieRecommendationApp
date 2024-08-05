import Foundation
import UIKit

enum RecommendationAlgorithms: String, CaseIterable {
    case contentBased = "Content Based"
    case collaborative = "Collaborative"
    
    var url: String {
        switch self {
        case .contentBased:
            "content"
        case .collaborative:
            "collaborative"
        }
    }
}

class RecommendationService {
    
    private var tmdbClientProvider = TMDbClientProvider()
    
    func getRecommendations(for userInput: [MovieStorageModel], _ algoSelection: RecommendationAlgorithms, completion: @escaping ([MovieUsableModel]?) -> Void) {
        
        let mockUserInput = [
            UserInput(id: 1018, rating: 5),
            UserInput(id: 605, rating: 5),
            UserInput(id: 604, rating: 5),
            UserInput(id: 603, rating: 5),
            UserInput(id: 103, rating: 5),
            UserInput(id: 559, rating: 5),
            UserInput(id: 206647, rating: 4),
            UserInput(id: 44826, rating: 1.5),
            UserInput(id: 257, rating: 3),
            UserInput(id: 9072, rating: 5)
        ]
        
        var userInput: [UserInput] = userInput.map { movie in
            UserInput(id: movie.id, rating: Double(movie.rating))
        }
        
        if userInput.count < 10 {
            userInput += Array(mockUserInput.prefix(upTo: (10 - userInput.count)))
        }
        
        guard let url = URL(string: "http://192.168.81.37:5000/recommend/\(algoSelection.url)") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let userInputArray = UserInputArray(userInput: userInput)
            let jsonData = try JSONEncoder().encode(userInputArray)
            request.httpBody = jsonData
            request.timeoutInterval = 10.0
        } catch {
            print("Failed to encode user input: \(error)")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching recommendations: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let recommendations = try JSONDecoder().decode(RecommendedMoviesResponse.self, from: data)
                self.loadMoviePosters(for: recommendations.ordered_recommended_movies, completion: completion)
            } catch {
                print("Failed to decode response: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func getCollaborativeRecommendations(completion: @escaping ([MovieUsableModel]?) -> Void) {
        let jsonData = """
        {
            "ordered_recommended_movies": [
                {"id": 1018}, {"id": 605}, {"id": 604}, {"id": 603}, {"id": 103},
                {"id": 9625}, {"id": 4474}, {"id": 291805}, {"id": 9766}, {"id": 11967},
                {"id": 4723}, {"id": 14043}, {"id": 8592}, {"id": 10783}, {"id": 27022},
                {"id": 58233}, {"id": 13811}, {"id": 10329}, {"id": 8961}, {"id": 4327}
            ]
        }
        """.data(using: .utf8)!
        
        do {
            let recommendations = try JSONDecoder().decode(RecommendedMoviesResponse.self, from: jsonData)
            loadMoviePosters(for: recommendations.ordered_recommended_movies, completion: completion)
        } catch {
            print("Failed to decode response: \(error)")
            completion(nil)
        }
    }
    
    func loadMoviePosters(for movies: [RecommendedMovie], completion: @escaping ([MovieUsableModel]?) -> Void) {
        Task {
            var usableMovies: [MovieUsableModel] = []
            
            for movie in movies {
                if let usableMovie = await loadMoviePoster(for: movie.id) {
                    usableMovies.append(usableMovie)
                }
            }
            
            DispatchQueue.main.async {
                completion(usableMovies)
            }
        }
    }
    
    func loadMoviePoster(for movieId: Int) async -> MovieUsableModel? {
        do {
            let movieDetails = try await tmdbClientProvider.client.movies.details(forMovie: movieId)
            let imagesConfiguration = try await tmdbClientProvider.client.configurations.apiConfiguration().images
            if let posterPath = movieDetails.posterPath, let url = imagesConfiguration.posterURL(for: posterPath) {
                let image = try await downloadImage(from: url)
                return MovieUsableModel(movie: movieDetails, image: image)
            }
        } catch {
            print("Failed to load movie poster: \(error)")
        }
        return nil
    }
    
    func downloadImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)!
    }
}
