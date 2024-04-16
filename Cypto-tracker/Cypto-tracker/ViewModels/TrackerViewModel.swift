//
//  TrackerViewModel.swift
//  Cypto-tracker
//
//  Created by Annmarie De Silva on 1/2/2024.
//

import Foundation
import Combine
import SwiftUI

class TrackerViewModel: ObservableObject {
    // MARK: Properties
    @Published var coins: [Cryptocurrency]
    
    private let service: CoinCapService
    private var disposeBag = Set<AnyCancellable>()
    
    // MARK: Init
    init(coins: [Cryptocurrency], service: CoinCapService = CoinCapService(), disposeBag: Set<AnyCancellable> = Set<AnyCancellable>()) {
        self.coins = coins
        self.service = service
        self.disposeBag = disposeBag
        self.service.connect()
        self.subscribeToService()
    }
    
    // MARK: Functions
    private func subscribeToService() {
        service.coinDictionarySubject
            .combineLatest(service.connectionStateSubject)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // update the view here
                self?.updateView()
            }
            .store(in: &disposeBag)
    }
    
    func updateView() {
        if self.service.isConnected {
            // update the value here
            self.coins = self.service.coinDictionary.map { $0.value }.sorted(by: { lhs, rhs in
                lhs.price > rhs.price
            })
            print("coins: \(self.coins)")
        } else {
            self.coins = []
            print("service not connected")
        }
        
    }
}
