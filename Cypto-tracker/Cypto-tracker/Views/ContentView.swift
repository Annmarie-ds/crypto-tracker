//
//  ContentView.swift
//  Cypto-tracker
//
//  Created by Annmarie De Silva on 16/1/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var sortOrder = [KeyPathComparator(\Cryptocurrency.price)]
    @ObservedObject var viewModel: TrackerViewModel
    
    var body: some View {
        VStack {
            Text(<#T##interval: DateInterval##DateInterval#>)
            
            Table(viewModel.coins) {
                TableColumn("Name", value: \.name)
                TableColumn("Value") { currency in
                    Text(String(currency.price))
                }
            }
            .onChange(of: sortOrder) { old, new in
                // TODO: Add sorting functionality
                viewModel.coins.sort(using: new)
            }
            .onAppear {
                viewModel.subscribeToService()
            }
        }
    }
}

#Preview {
    ContentView(
        viewModel: TrackerViewModel(
            coins: [Cryptocurrency(name: "Bitcoin", price: 42574.03),
                    Cryptocurrency(name: "Ethereum",price: 2514.23)]
        )
    )
}
