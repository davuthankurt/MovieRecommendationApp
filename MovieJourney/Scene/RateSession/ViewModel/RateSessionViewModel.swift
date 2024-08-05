//
//  RateSessionViewModel.swift
//  MovieJourney
//
//  Created by Abdullah Ayan on 29.05.2024.
//

import Foundation

class RateSessionViewModel: ObservableObject {
    @Published var movies = MovieDatasetController.shared.rateSession()
    @Published var progressArray: [CGFloat] = MovieDatasetController.movies.map { _ in 0 }

    func addMovie() {
        Task {
            guard let movie = await MovieDatasetController.shared.randomMovie() else { return }
            movies.append(movie)
        }
    }
}
