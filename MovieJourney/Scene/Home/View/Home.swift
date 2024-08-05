//
//  Home.swift
//  MovieAppUI
//
//  Created by Balaji on 08/08/22.
//

import SwiftUI
import SwiftData

struct Home: View {
    
    @Query var movies: [MovieStorageModel]
    
    @State var selectedMovie: MovieUsableModel?
    @State var showDetail = false
    @State var currentIndex: Int = 0
    @State var usableMovies: [MovieUsableModel] = []
    @State var algoSelection = RecommendationAlgorithms.contentBased
    var recommendationService = RecommendationService()
    
    var body: some View {
        VStack(spacing: 15){
            HeaderView()
            
            Spacer()
            
            HStack {
                (Text("Recommended")
                    .fontWeight(.semibold) +
                 Text("\nMovies")
                )
                .font(.title2)
                .frame(maxWidth: .infinity,alignment: .leading)
                .padding(.top,15)
                
                Spacer()
                
                Picker(selection: $algoSelection) {
                    ForEach(RecommendationAlgorithms.allCases, id: \.self) { algo in
                        Text(algo.rawValue)
                    }
                } label: {
                    Text(algoSelection.rawValue)
                }
                .tint(.white)
            }
            
            // MARK: Custom Carousel
            CustomCarousel(index: $currentIndex,
                           items: usableMovies,
                           cardPadding: 150,
                           id: \.self) { movie, cardSize in
                Image(uiImage: movie.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: cardSize.width + 20,
                           height: cardSize.height + 20)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        )
                    )
                    .onTapGesture {
                        selectedMovie = movie
                    }
            }
                           .padding(.horizontal, -15)
                           .padding(.vertical)
                           .overlay {
                               if usableMovies.isEmpty {
                                   ProgressView()
                                       .controlSize(.large)
                               }
                           }
            
        }
        .padding([.horizontal,.top], 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            GeometryReader { proxy in
                let size = proxy.size
                
                TabView(selection: $currentIndex) {
                    ForEach(usableMovies.indices, id: \.self){ index in
                        Image(uiImage: usableMovies[index].image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipped()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentIndex)
                
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
        .onAppear {
            recommendationService.getRecommendations(for: movies, algoSelection) { response in
                guard let response else { return }
                usableMovies = response
            }
        }
        .onChange(of: algoSelection) { oldValue, newValue in
            recommendationService.getRecommendations(for: movies, algoSelection) { response in
                guard let response else { return }
                usableMovies = response
            }
        }
        .sheet(item: $selectedMovie) { selectedMovie in
            MovieDetailView(movie: selectedMovie)
        }
    }
    
    // MARK: Search Bar
    @ViewBuilder
    func SearchBar() -> some View{
        HStack(spacing: 15){
            Image("Search")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .foregroundColor(.gray)
            
            TextField("Search",text: .constant(""))
                .padding(.vertical,10)
            
            Image("Mic")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.vertical,6)
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.white.opacity(0.12))
        }
        .padding(.top, 20)
    }
    
    // MARK: Header View
    @ViewBuilder
    func HeaderView() -> some View{
        HStack{
            VStack(alignment: .leading, spacing: 6) {
                (Text("Hello")
                    .fontWeight(.semibold) +
                 Text(" User")
                )
                .font(.title2)
                
                Text("Find recommended movies for you")
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity,alignment: .leading)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
