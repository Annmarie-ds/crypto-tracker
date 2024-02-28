//
//  Cryptocurrency.swift
//  Cypto-tracker
//
//  Created by Annmarie De Silva on 16/1/2024.
//

import Foundation

struct Cryptocurrency: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Double
}
