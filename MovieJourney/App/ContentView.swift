//
//  ContentView.swift
//  MovieJourney
//
//  Created by Abdullah Ayan on 4.05.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: View Properties
    @Namespace var animation
    @State var currentTab: Tab = .home
    
    var body: some View {
        ZStack {
            switch currentTab {
            case .home:
                Home()
            case .explore:
                RateSession()
            case .profile:
                RatedMovies()
            }
            
            VStack {
                Spacer()
                TabBar()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: Custom Tab Bar
    @ViewBuilder
    func TabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases,id: \.rawValue) { tab in
                VStack(spacing: -2){
                    Image(tab.rawValue)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .foregroundColor(currentTab == tab ? .white : .gray.opacity(0.6))
                    
                    if currentTab == tab {
                        Circle()
                            .fill(.white)
                            .frame(width: 5, height: 5)
                            .offset(y: 10)
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    currentTab = tab
                }
            }
        }
        .animation(.easeInOut, value: currentTab)
        .padding(.horizontal)
        .padding(.bottom,10)
    }
}

#Preview {
    ContentView()
}
