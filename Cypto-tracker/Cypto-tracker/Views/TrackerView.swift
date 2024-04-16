//
//  TrackerView.swift
//  Cypto-tracker
//
//  Created by Annmarie De Silva on 16/1/2024.
//

import SwiftUI

struct TrackerView: View {
    @State private var sortOrder = [KeyPathComparator(\Cryptocurrency.price)]
    @ObservedObject var viewModel: TrackerViewModel
    
    var body: some View {
        List {
            Grid {
                GridRow {
                    Text("Rank")
                    Text("Name")
                    Text("Price")
                }
                .bold()
                Divider()
                ForEach(Array(viewModel.coins.enumerated()), id: \.1) { (index, value) in
                    GridRow {
                        Text("\(index + 1)")
                        Text(value.name)
                        Text("\(value.price)")
                    }
                    
                }
            }
        }
    }
}

#Preview {
    TrackerView(
        viewModel: TrackerViewModel(
            coins: [Cryptocurrency(name: "Bitcoin", price: 42574.03),
                    Cryptocurrency(name: "Ethereum",price: 2514.23),
                    Cryptocurrency(name: "Tether",price: 2514.23)]
        )
    )
}
