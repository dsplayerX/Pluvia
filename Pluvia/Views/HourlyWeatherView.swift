//
//  HourlyWeatherView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct HourlyWeatherView: View {

    // MARK:  set up the @EnvironmentObject for WeatherMapPlaceViewModel
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    var body: some View {
        VStack(alignment: .leading) {
            if let weatherData = weatherMapPlaceViewModel.weatherDataModel {
                Text(weatherData.daily[0].summary)
                    .foregroundColor(.white)
                    .font(.caption)

                Divider().background(Color.white)

                HourlyWeatherListView(weatherData: weatherData)
            } else {
                HStack{
                    Text("Loading...")
                        .foregroundColor(.white)
                        .font(.caption)
                    Spacer()
                }
            }
        }
        .padding(10)
        .background(Color.gray.opacity(0.6))
        .cornerRadius(10)
        .padding(10)
        // TODO: remove, only for testing
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
//                }
//            }
//        }
    }
}
#Preview {
    HourlyWeatherView().environmentObject(WeatherMapPlaceViewModel())

}

struct HourlyWeatherListView: View {
    var weatherData: WeatherDataModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(weatherData.hourly, id: \.id) { hour in
                    VStack {
                        Text(
                            DateFormatterUtils.formattedDate12Hour(
                                from: TimeInterval(hour.dt),
                                timeZone: TimeZone(identifier: weatherData.timezone) ?? .current
                            )
                        )
                        .foregroundColor(.white)
                        .font(.caption)
                        
                        Image(
                            systemName: mapWeatherIcon(
                                for: hour.weather.first?.id ?? 800)
                        )
                        .foregroundColor(.white)
                        .font(.title2)
                        
                        Text("\(Int(hour.temp))°")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    // Map weather condition IDs to system icons
    func mapWeatherIcon(for conditionID: Int) -> String {
        switch conditionID {
        case 200...232:
            return "cloud.bolt.rain.fill"  // Thunderstorm
        case 300...321:
            return "cloud.drizzle.fill"  // Drizzle
        case 500...531:
            return "cloud.rain.fill"  // Rain
        case 600...622:
            return "cloud.snow.fill"  // Snow
        case 701...781:
            return "cloud.fog.fill"  // Atmosphere
        case 800:
            return "sun.max.fill"  // Clear
        case 801...804:
            return "cloud.fill"  // Clouds
        default:
            return "questionmark"  // Unknown
        }
    }
}
