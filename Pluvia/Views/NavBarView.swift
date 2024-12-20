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

            VStack{
                // MARK:  Add view(s) that are common to all tabbed views e.g. - images, textfields, etc
                Image("wmin")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.5)
                //                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: 70)
            } //VStack - Inner
            TabView {
                CurrentWeatherView()
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
                VisitedPlacesView(cities: [City(name: "London", temperature: "12", condition: "Rainy"), City(name: "Paris", temperature: "15", condition: "Sunny"), City(name: "New York", temperature: "10", condition: "Cloudy")])
                    .tabItem{
                        Label("Stored Places", systemImage: "globe")
                    }
            } // TabView
            .onAppear {
                // MARK:  Write code to manage what happens when this view appears
            }

        }//VStack - Outer
        // add frame modifier and other modifiers to manage this view
    }
}

#Preview {
    NavBarView()
}
