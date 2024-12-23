//
//  HourlyWeatherView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftData
import SwiftUI

struct HourlyWeatherView: View {

    // MARK:  set up the @EnvironmentObject for WeatherMapPlaceViewModel
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    var body: some View {
        VStack(alignment: .leading) {
            if let weatherData = weatherMapPlaceViewModel.weatherDataModel {
                Text(weatherData.daily[0].summary)
                    .foregroundColor(.white)
                    .font(.system(size: 14)).padding(.vertical, 5)

                Divider().background(Color.white)

                HourlyWeatherListView(weatherData: weatherData)
            } else {
                HStack(alignment: .top) {
                    Text("Loading...")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                    Spacer()
                }
            }
        }
        .frame(minHeight: 150)
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding(.horizontal, 20)
        .padding(.vertical, 2.5)
    }
}

struct HourlyWeatherListView: View {
    var weatherData: WeatherDataModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 20) {
                ForEach(weatherData.hourly, id: \.id) { hour in
                    VStack(alignment: .center) {
                        Text(
                            DateFormatterUtils.formattedDate24Hour(
                                from: TimeInterval(hour.dt),
                                timeZone: TimeZone(
                                    identifier: weatherData.timezone)
                                    ?? .current
                            )
                        )
                        .foregroundColor(.white)
                        .font(.system(size: 14)).fontWeight(.medium).padding(
                            .top, 5
                        ).padding(.bottom, 10)

                        Spacer()

                        HourlyWeatherIconView(
                                conditionID: hour.weather.first?.id ?? 800,
                                dt: hour.dt,
                                timezone: weatherData.timezone,
                                pop: hour.pop
                        )
                            
                        Text("\(Int(hour.temp))°")
                            .foregroundColor(.white)
                            .font(.system(size: 20)).fontWeight(.medium)
                            .padding(.bottom, 5)
                    }
                }
            }
        }
    }

}

struct HourlyWeatherIconView: View {
    let conditionID: Int
    let dt: Int
    let timezone: String
    let pop: Double?
    
    var body: some View {
        VStack {
            Image(
                systemName: mapWeatherIcon(
                    for: conditionID,
                    dt: dt,
                    timezone: timezone
                )
            )
            .resizable()
            .scaledToFit()
            .frame(height: 16)
            .foregroundColor(.white)
            .padding(.bottom, 0)
            
            if let pop = pop, pop > 0 {
                Text("\(Int(pop * 100))%")
                    .foregroundColor(.cyan)
                    .font(.system(size: 10))
            }
        }.frame(height: 50)
        .frame(maxWidth: .infinity)
    }
    
    // Maps the weather condition ID to an SF Symbol name based on day/night
    private func mapWeatherIcon(for conditionID: Int, dt: Int, timezone: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(dt))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: timezone) ?? .current
        formatter.dateFormat = "HH"
        let hour = Int(formatter.string(from: date)) ?? 0
        let isDay = (hour >= 6 && hour < 18)

        switch conditionID {
        case 200...232:
            return "cloud.bolt.fill" // Thunderstorm
        case 300...321:
            return isDay
                ? "cloud.sun.drizzle.fill" : "cloud.moon.drizzle.fill"  // Drizzle
        case 500...531:
            return "cloud.rain.fill"  // Rain
        case 600...622:
            return "cloud.snow.fill"  // Snow
        case 701...781:
            return isDay ? "cloud.sun.fog.fill" : "cloud.moon.fog.fill"  // Atmosphere
        case 800:
            return isDay ? "sun.max.fill" : "moon.fill"  // Clear sky
        case 801:
            return isDay ? "cloud.sun.fill" : "cloud.moon.fill"  // Few clouds
        case 802...804:
            return "cloud.fill"  // Overcast
        default:
            return "questionmark"  // Unknown
        }
    }
}
