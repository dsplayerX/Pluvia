//
//  CurrentWeatherView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct CurrentWeatherView: View {

// MARK:  set up the @EnvironmentObject for WeatherMapPlaceViewModel
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    var city: String
    
// MARK:  set up local @State variable to support this view
    var body: some View {
        ScrollView{
            TopWeatherView()
            ForecastWeatherView()
        }.onAppear{
            Task {
                    do {
                        weatherMapPlaceViewModel.setNewLocation(city)
                        let coordinates = try await weatherMapPlaceViewModel.getCoordinatesForCity()
                        try await weatherMapPlaceViewModel.fetchWeatherData(lat: coordinates.latitude, lon: coordinates.longitude)
                        try await weatherMapPlaceViewModel.fetchAirQualityData(lat: coordinates.latitude, lon: coordinates.longitude)
                    } catch {
                        weatherMapPlaceViewModel.errorMessage = error.localizedDescription
                    }
                }
        }
    }
}

#Preview {
    CurrentWeatherView(city: "London")
        .background(Color.blue)
        .environmentObject(WeatherMapPlaceViewModel())
}
