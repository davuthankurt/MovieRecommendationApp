//
//  RateSession.swift
//  MovieJourney
//
//  Created by Abdullah Ayan on 28.05.2024.
//

import SwiftUI
import TMDb

class TMDbClientProvider: ObservableObject {
    let client = TMDbClient(apiKey: "22f19b80e5fdd95e19f7617af359964c")
}

struct MovieRating: Equatable {
    let index: Int
    var rating: Int
    let movie: MovieUsableModel
}

struct RateSession: View {
    @Environment(\.modelContext) var modelContext

    @State private var currentIndex: Int = 0
    @State private var ratings: [MovieRating] = []
    @State private var showDetail = false
    @State private var heroID: String? = nil
    
    @State var movies = MovieDatasetController.shared.rateSession()
    @State var progressArray: [CGFloat] = MovieDatasetController.movies.map { _ in 0 }
    @State var maxIndex: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {                
                GeometryReader { geometry in
                    let size = geometry.size
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(Array(movies.enumerated()), id: \.offset) { index, movie in
                                CardView(movie: movie,
                                         itemIndex: index,
                                         progress: $progressArray[index],
                                         currentIndex: $currentIndex,
                                         ratings: $ratings,
                                         movies: $movies)
                                .onTapGesture {
                                    withAnimation {
                                        showDetail = true
                                        heroID = "\(index)"
                                    }
                                }
                                .padding(.horizontal, 65)
                                .frame(width: size.width)
                                .visualEffect { content, geometryProxy in
                                    content
                                        .scaleEffect(scale(geometryProxy, scale: 0.1, index: index), anchor: .trailing)
                                        .rotationEffect(rotation(geometryProxy, rotation: 5))
                                        .offset(x: minX(geometryProxy))
                                        .offset(x: excessMinX(geometryProxy, offset: 6))
                                }
                                .background {
                                    GeometryReader { proxy in
                                        Color.clear
                                            .onChange(of: proxy.frame(in: .global).minX) { _, _ in
                                                updateProgress(proxy: proxy, index: index)
                                            }
                                    }
                                }
                                .zIndex(Double(movies.count - index))
                            }
                        }
                        .padding(.vertical, 15)
                    }
                    .scrollTargetBehavior(.paging)
                }
            }
            .background(background)
            .navigationTitle("Discover")
        }
        .sheet(isPresented: $showDetail) {
            if let heroID = heroID, let index = Int(heroID) {
                MovieDetailView(movie: movies[index])
            }
        }
        .onChange(of: currentIndex) { old, new in
            if new > maxIndex {
                maxIndex = new
                addMovie()
            }
        }
        .onDisappear {
            ratings.forEach { rating in
                let data = MovieStorageModel(id: rating.movie.id, rating: rating.rating)
                modelContext.insert(data)
            }
        }
    }
    
    func addMovie() {
        Task {
            guard let movie = await MovieDatasetController.shared.randomMovie() else { return }
            progressArray.append(0)
            movies.append(movie)
        }
    }
    
    private var background: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            TabView(selection: $currentIndex) {
                ForEach(Array(movies.enumerated()), id: \.offset) { index, movie in
                    MoviePoster(movie: movie)
                        .frame(width: size.width, height: size.height)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Rectangle()
                .fill(.thinMaterial)
        }
        .ignoresSafeArea()
    }
    
    private func getRecommendation() {
        // Your recommendation logic
    }
    
    private func updateProgress(proxy: GeometryProxy, index: Int) {
        let progress = calculateProgress(proxy)
        progressArray[index] = progress
    }
    
    private func calculateProgress(_ proxy: GeometryProxy, limit: CGFloat = 2) -> CGFloat {
        let maxX = proxy.frame(in: .global).maxX
        let width = proxy.size.width
        let progress = (maxX / width) - 1.0
        return min(progress, limit)
    }
    
    private func minX(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        return minX < 0 ? 0 : -minX
    }
    
    private func scale(_ proxy: GeometryProxy, scale: CGFloat = 0.1, index: Int) -> CGFloat {
        let progress = calculateProgress(proxy)
        return 1 - (progress * scale)
    }
    
    private func excessMinX(_ proxy: GeometryProxy, offset: CGFloat = 10) -> CGFloat {
        let progress = calculateProgress(proxy)
        return progress * offset
    }
    
    private func rotation(_ proxy: GeometryProxy, rotation: CGFloat = 5) -> Angle {
        let progress = calculateProgress(proxy)
        return .degrees(progress * rotation)
    }
}

struct CardView: View {
        
    var movie: MovieUsableModel
    var itemIndex: Int
    @Binding var progress: CGFloat
    @Binding var currentIndex: Int
    @Binding var ratings: [MovieRating]
    
    @State private var rating: Int = 0
    @Binding var movies: [MovieUsableModel]

    var body: some View {
        VStack(spacing: 15) {
            MoviePoster(movie: movie)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(height: 500)
            
            RatingView(rating: $rating)
                .opacity(calculateOpacity(progress: progress))
                .onChange(of: rating) { old, newRating in
                    if let existingIndex = ratings.firstIndex(where: { $0.index == itemIndex }) {
                        ratings[existingIndex].rating = newRating
                    } else if newRating != 0 {
                        ratings.append(MovieRating(index: itemIndex, rating: newRating, movie: movie))
                    }
                }
            
            Spacer()
            Spacer()
        }
    }
    
    private func calculateOpacity(progress: CGFloat) -> Double {
        if movies.count - 1 == itemIndex {
            return 0
        }
        let opacity = 1 - progress
        if opacity <= 1 && opacity > 0.5 {
            DispatchQueue.main.async {
                if currentIndex != itemIndex {
                    currentIndex = itemIndex
                }
            }
        }
        return opacity
    }
}


struct MoviePoster: View {
    var movie: MovieUsableModel
    
    var body: some View {
        Image(uiImage: movie.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
    }
}

struct MovieDetailView: View {
    var movie: MovieUsableModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Image(uiImage: movie.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                
                Text(movie.movie.title)
                    .font(.largeTitle)
                    .padding(.horizontal)
                
                Text(movie.movie.genres?.reduce(into: "", { partialResult, genre in
                    partialResult += genre.name + ", "
                }) ?? "")
                    .font(.subheadline)
                    .padding(.horizontal)

                Text(movie.movie.overview ?? "")
                    .padding(.horizontal)
                
                Spacer()
            }
        }
        .background(.black)
    }
}
