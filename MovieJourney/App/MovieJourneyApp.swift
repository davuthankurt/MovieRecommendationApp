//
//  MovieJourneyApp.swift
//  MovieJourney
//
//  Created by Abdullah Ayan on 4.05.2024.
//

import SwiftUI
import SwiftData

@main
struct MovieJourneyApp: App {
    @StateObject private var tmdbClientProvider = TMDbClientProvider()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tmdbClientProvider)
                .task {
                    MovieDatasetController.parseDataset()
                }
        }
        .modelContainer(for: MovieStorageModel.self)
    }
}
