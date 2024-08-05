//
//  Item.swift
//  StackedCards
//
//  Created by Balaji Venkatesh on 05/03/24.
//

import SwiftUI

class Item: ObservableObject, Identifiable {
    var id: UUID = .init()
    var color: Color
    @Published var progress: CGFloat = 1
    
    init(color: Color) {
        self.color = color
    }
}

var items: [Item] = [
    .init(color: .red),
    .init(color: .blue),
    .init(color: .green),
    .init(color: .yellow),
    .init(color: .pink),
    .init(color: .purple),
]

extension [Item] {
    func zIndex(_ item: Item) -> CGFloat {
        if let index = firstIndex(where: { $0.id == item.id }) {
            return CGFloat(count) - CGFloat(index)
        }
        
        return .zero
    }
}
