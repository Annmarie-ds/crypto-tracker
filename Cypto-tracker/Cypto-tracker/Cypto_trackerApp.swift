//
//  Cypto_trackerApp.swift
//  Cypto-tracker
//
//  Created by Annmarie De Silva on 16/1/2024.
//

import SwiftUI

@main
struct Cypto_trackerApp: App {
    var body: some Scene {
        WindowGroup {
            // Maybe cache the previous load to begin with?
            TrackerView(viewModel: TrackerViewModel(coins: []))
        }
    }
}
