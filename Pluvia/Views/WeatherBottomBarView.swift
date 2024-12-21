//
//  WeatherBottomBar.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-20.
//

import SwiftUI

struct WeatherStyleBottomBarView: View {

    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    @State private var selectedCityIndex = 0
    @State private var isMapViewPresented = false
    @State private var isListViewPresented = false

    // Dummy city data with weather info
    let cities = [
        City(name: "Horana"),
        City(name: "Kolkata"),
        City(name: "Washington"),
        City(name: "Sydney"),
        City(name: "Paris"),
        City(name: "Battaramulla")
    ]

    var body: some View {
        VStack {
            TabView(selection: $selectedCityIndex) {
                ForEach(0..<cities.count, id: \.self) { index in
                    VStack() {
                        CurrentWeatherView(city: cities[index].name)
                    }
                    .tag(index)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedCityIndex)
            
            // Bottom Bar
            HStack {
                // Map Button
                Button(action: {
                    isMapViewPresented.toggle()
                }) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .sheet(isPresented: $isMapViewPresented) {
                    MapView()
                }
                .padding(.leading, 20)

                Spacer()

                // Dot Indicators
                HStack(spacing: 8) {
                    ForEach(0..<cities.count, id: \.self) { index in
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(
                                index == selectedCityIndex ? .white : .gray
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedCityIndex = index
                                }
                            }
                    }
                }

                Spacer()

                // List Button
                Button(action: {
                    isListViewPresented.toggle()
                }) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .sheet(isPresented: $isListViewPresented) {
                    VisitedPlacesView(cities: cities)
                }
                .padding(.trailing, 20)
            }
            .padding()
            .background(Color.gray.opacity(0.5))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
            
            .ignoresSafeArea()
        }
        .background(Color.blue.opacity(1))
//        .onAppear {
//            Task {
//                do {
//                    let coordinates =
//                        try await weatherMapPlaceViewModel.getCoordinatesForCity()
//                    try await weatherMapPlaceViewModel.fetchWeatherData(
//                        lat: coordinates.latitude, lon: coordinates.longitude)
//                    try await weatherMapPlaceViewModel.fetchAirQualityData(
//                        lat: coordinates.latitude, lon: coordinates.longitude)
//                } catch {
//                    weatherMapPlaceViewModel.errorMessage =
//                        error.localizedDescription
//                    print("Error: \(error.localizedDescription)")
//                }
//            }
//        }
    }
}

struct City {
    let name: String
}

struct WeatherStyleBottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherStyleBottomBarView().environmentObject(
            WeatherMapPlaceViewModel())
        //   .preferredColorScheme(.dark) // To simulate the iOS Weather app style
    }
}
