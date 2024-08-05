//
//  RecommendationServiceModels.swift
//  MovieJourney
//
//  Created by Abdullah Ayan on 29.05.2024.
//

import Foundation
import UIKit
import TMDb
import SwiftData

// Data model for user input
struct UserInput: Codable {
    let id: Int
    let rating: Double
}

// Data model for user input array
struct UserInputArray: Codable {
    let userInput: [UserInput]
}

// Data model for the response
struct RecommendedMoviesResponse: Codable {
    let ordered_recommended_movies: [RecommendedMovie]
}

// Data model for recommended movie
struct RecommendedMovie: Codable {
    let id: Int
}

struct MovieUsableModel: Equatable, Hashable, Identifiable {
    var id: Int {
        movie.id
    }
    let movie: TMDb.Movie
    let image: UIImage
}

@Model
class MovieStorageModel {
    let id: Int
    var rating: Int
    
    init(id: Int, rating: Int) {
        self.id = id
        self.rating = rating
    }
}
