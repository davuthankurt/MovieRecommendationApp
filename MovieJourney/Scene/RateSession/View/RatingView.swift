//
//  RatingView.swift
//  MovieJourney
//
//  Created by Abdullah Ayan on 28.05.2024.
//

import SwiftUI

struct RatingView: View {
    var size: CGFloat = 35
    @Binding var rating: Int
    
    var body: some View {
        HStack {
            ForEach(1..<6) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(index <= rating ? .yellow : .white.opacity(0.5))
                    .onTapGesture {
                        rating = index
                    }
            }
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.8))
        .background(.purple.opacity(0.1))
        .clipShape(.rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white, lineWidth: 0.5)
        }
    }
}

#Preview {
    RatingView(rating: .constant(0))
}
