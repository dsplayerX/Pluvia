//
//  PluviaApp.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-18.
//

import SwiftUI
import SwiftData

@main
struct PluviaApp: App {
    @StateObject private var weatherMapPlaceViewModel = WeatherMapPlaceViewModel()

    var body: some Scene {
        WindowGroup {
            WeatherStyleBottomBarView()
                .environmentObject(weatherMapPlaceViewModel)
        }
    }
}
