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
    let container: ModelContainer
    var body: some Scene {
            WindowGroup {
                WeatherStyleBottomBarView()
            }.environmentObject(
                WeatherMapPlaceViewModel(modelContext: container.mainContext)
            )
            .modelContainer(container)
        }
    
    init() {
        do {
            container = try ModelContainer(for: LocationModel.self)
            
            // Initialize context and fetch all locations
            let context = container.mainContext
            let allLocationsDescriptor = FetchDescriptor<LocationModel>() // Fetch all locations

            // Check if there are any saved locations
            let allLocations = try context.fetch(allLocationsDescriptor)
            if allLocations.isEmpty {
                // No locations saved, insert London
                let londonLocation = LocationModel(
                    name: "London",
                    latitude: 51.5074,
                    longitude: -0.1278
                )
                context.insert(londonLocation)
                try context.save()
            }
        } catch {
            fatalError("Failed to initialize LocationModel or save default location: \(error.localizedDescription)")
        }
    }
}


