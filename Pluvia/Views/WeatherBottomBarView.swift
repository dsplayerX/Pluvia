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
        City(name: "New York", temperature: "24°", condition: "Cloudy"),
        City(name: "London", temperature: "18°", condition: "Rainy"),
        City(name: "Tokyo", temperature: "30°", condition: "Sunny"),
        City(name: "Sydney", temperature: "22°", condition: "Windy"),
        City(name: "Paris", temperature: "19°", condition: "Foggy"),
    ]

    var body: some View {
        VStack {
            // Temprary shwo weather data for tessting
            TabView(selection: $selectedCityIndex) {
                ForEach(0..<cities.count, id: \.self) { index in
                    VStack(spacing: 10) {
                        Text(cities[index].name)
                            .font(.largeTitle)
                            .bold()
                        Text(
                            "\(cities[index].temperature) | \(cities[index].condition)"
                        )
                        .font(.title2)
                        .foregroundColor(.gray)
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
            .background(Color.gray)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: -2)

        }.onAppear {  
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
        }
    }
}

struct City {
    let name: String
    let temperature: String
    let condition: String
}

struct WeatherStyleBottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherStyleBottomBarView().environmentObject(
            WeatherMapPlaceViewModel())
        //   .preferredColorScheme(.dark) // To simulate the iOS Weather app style
    }
}
