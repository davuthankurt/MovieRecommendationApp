//
//  RatedMovies.swift
//  MovieJourney
//
//  Created by Abdullah Ayan on 30.05.2024.
//

import SwiftUI
import SwiftData

struct RatedMovies: View {
    @Environment(\.modelContext) var modelContext

    @Query var movies: [MovieStorageModel]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(movies) { movie in
                    MovieRow(movie: movie)
                }
                .onDelete { indexSet in
                    deleteMovies(indexSet)
                }
            }
            .background {
                ZStack {
                    Rectangle()
                        .fill(.thinMaterial)
                    
                    LinearGradient(colors: [
                        .clear,
                        Color("BGTop"),
                        Color("BGBottom")
                    ], startPoint: .top, endPoint: .bottom)
                }
                .ignoresSafeArea()
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Your Ratings")
        }
    }
}

extension RatedMovies {
    
    func deleteMovies(_ indexSet: IndexSet) {
        for index in indexSet {
            let movie = movies[index]
            modelContext.delete(movie)
        }
    }
}

struct MovieRow: View {
    @State var movie: MovieStorageModel
    @State var usableMovie: MovieUsableModel?
    @State var isPresented = false
    var body: some View {
        HStack(spacing: 20) {
            if let usableMovie {
                Image(uiImage: usableMovie.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 130)
                    .clipShape(.rect(cornerRadius: 10))
                    .transition(.opacity)
                
                VStack(alignment: .leading) {
                    Text(usableMovie.movie.title)
                        .font(.headline)
                    Spacer()
                    RatingView(size: 15, rating: $movie.rating)
                    Spacer()
                }
            }
            
        }
        .animation(.easeInOut, value: usableMovie)
        .padding()
        .listRowInsets(EdgeInsets())
        .task {
            await usableMovie = MovieDatasetController.shared.movieUsableModel(for: movie.id)
        }
        .onTapGesture {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            if let usableMovie {
                MovieDetailView(movie: usableMovie)
            }
        }
    }
}

//#Preview {
//    RatedMovies()
//        .modelContainer(for: MovieStorageModel.self)
//}
