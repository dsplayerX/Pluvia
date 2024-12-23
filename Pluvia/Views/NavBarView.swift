//
//  NavBarView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct NavBarView: View {

    // MARK:  Varaible section - set up variable to use WeatherMapPlaceViewModel and SwiftData

    /*
     set up the @EnvironmentObject for WeatherMapPlaceViewModel
     Set up the @Environment(\.modelContext) for SwiftData's Model Context
     Use @Query to fetch data from SwiftData models

     State variables to manage locations and alertmessages
     */
    
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @Environment(\.modelContext) private var modelContext // SwiftData's model context (mock example for now)
    
    @State private var alertMessage: String? // To manage alert messages


    // MARK:  Configure the look of tab bar

    init() {
        // Customize TabView appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
    }

    var body: some View {
        VStack{
            TabView {
                CurrentWeatherView().background(Color.blue)
                    .tabItem{
                        Label("Now", systemImage:  "sun.max.fill")
                    }

                ForecastWeatherView()
                    .tabItem{
                        Label("5-Day Weather", systemImage: "calendar")
                    }
                MapView()
                    .tabItem {
                        Label("Place Map", systemImage: "map")
                    }
                VisitedPlacesView()
                    .tabItem{
                        Label("Stored Places", systemImage: "globe")
                    }
            } // TabView
            .onAppear {
                // MARK:  Write code to manage what happens when this view appears
                Task {
                        do {
                            let coordinates = try await weatherMapPlaceViewModel.getCoordinatesForCity()
                            try await weatherMapPlaceViewModel.fetchWeatherData(lat: coordinates.latitude, lon: coordinates.longitude)
                            try await weatherMapPlaceViewModel.fetchAirQualityData(lat: coordinates.latitude, lon: coordinates.longitude)
                        } catch {
                            weatherMapPlaceViewModel.errorMessage = AlertMessage(message: error.localizedDescription)
                        }
                    }
            }

        }//VStack - Outer
        // add frame modifier and other modifiers to manage this view
    }
}

//#Preview {
//    NavBarView()
//        .environmentObject(WeatherMapPlaceViewModel()) 
//}
