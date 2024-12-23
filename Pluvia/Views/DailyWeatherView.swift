//
//  DailyWeatherView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct DailyWeatherView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "calendar").foregroundColor(
                    Color.white.opacity(0.7))
                Text("7-DAY FORECAST").foregroundColor(
                    Color.white.opacity(0.7)
                ).font(.system(size: 14))
            }
            Divider().background(Color.white)
            if let weatherData = weatherMapPlaceViewModel.weatherDataModel {
                forecastListView(weatherData: weatherData)
            } else {
                HStack {
                    Text("Loading...")
                        .foregroundColor(.white)
                        .font(.caption)
                    Spacer()
                }
            }
        }.padding(10).background(.ultraThinMaterial).cornerRadius(15)
            .padding(.horizontal, 20)
            .padding(.vertical, 2.5)
    }

    private func forecastListView(weatherData: WeatherDataModel) -> some View {

        let globalMinTemp = weatherData.daily.map { $0.temp.min }.min() ?? 0.0
        let globalMaxTemp = weatherData.daily.map { $0.temp.max }.max() ?? 0.0
        let currentTemp = weatherData.current.temp  // Replace with actual current temp from your model
        return VStack {

            ForEach(
                Array(weatherData.daily.prefix(7).enumerated()),
                id: \.element.id
            ) { index, day in
                DailyWeatherRowView(
                    index: index, day: day, globalMinTemp: globalMinTemp,
                    globalMaxTemp: globalMaxTemp,
                    currentTemp: currentTemp)
            }
        }
    }
}

struct DailyWeatherRowView: View {
    let index: Int
    let day: Daily
    let globalMinTemp: Double
    let globalMaxTemp: Double
    let currentTemp: Double

    var body: some View {
        HStack {
            Text(index == 0 ? "Today" : formatDayLabel(for: day.dt))
                .foregroundColor(.white)
                .font(.headline)
                .frame(width: 100, alignment: .leading)

            VStack {
                Image(
                    systemName: mapWeatherIcon(
                        for: day.weather.first?.id ?? 800)
                )
                .foregroundColor(.white)
                .font(.system(size: 20))
                if day.pop > 0 {
                    Text("\(Int(day.pop * 100))%")
                        .foregroundColor(.cyan)
                        .font(.system(size: 12))
                }
            }
            Spacer()

            // Minimum temperature
            Text("\(Int(day.temp.min))°")
                .foregroundColor(.white)
                .font(.caption)

            TempBarView(
                index: index,
                minTemp: Int(day.temp.min),
                maxTemp: Int(day.temp.max),
                globalMinTemp: Int(globalMinTemp),
                globalMaxTemp: Int(globalMaxTemp),
                currentTemp: Int(
                    index == 0 ? currentTemp : (day.temp.min + day.temp.max) / 2
                )
            )
            .frame(height: 5)
            .padding(.horizontal, 5)

            // Maximum temperature
            Text("\(Int(day.temp.max))°")
                .foregroundColor(.white)
                .font(.caption)
        }
        .padding(.vertical, 5)
    }

    // Format day label
    private func formatDayLabel(for timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"  // Day of the week
        return formatter.string(from: date)
    }

    // Map weather condition IDs to system icons
    private func mapWeatherIcon(for conditionID: Int) -> String {
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

struct TempBarView: View {
    let index: Int
    let minTemp: Int
    let maxTemp: Int
    let globalMinTemp: Int
    let globalMaxTemp: Int
    let currentTemp: Int  // Pass the current temperature dynamically

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full gradient background
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .orange, .red]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 5)
                .cornerRadius(2.5)
                .mask(
                    Rectangle()
                        .frame(
                            width: geometry.size.width
                                * CGFloat(croppedWidthRatio),
                            alignment: .leading
                        )
                        .offset(
                            x: geometry.size.width * CGFloat(startOffsetRatio))
                )

                // Dot for Current Temperature (only for "Today")
                if index == 0 {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .offset(
                            x: geometry.size.width * CGFloat(dotPosition)
                                - geometry.size.width / 2)
                }
            }
        }
    }

    // Ratio for cropping the gradient width
    private var croppedWidthRatio: Double {
        let globalRange = globalMaxTemp - globalMinTemp
        guard globalRange > 0 else { return 1.0 }
        return Double(maxTemp - minTemp) / Double(globalRange)
    }

    // Offset ratio to start the gradient crop
    private var startOffsetRatio: Double {
        let globalRange = globalMaxTemp - globalMinTemp
        guard globalRange > 0 else { return 0.0 }
        return Double(minTemp - globalMinTemp) / Double(globalRange)
    }

    // Position of the dot relative to the gradient
    private var dotPosition: Double {
        let globalRange = globalMaxTemp - globalMinTemp
        guard globalRange > 0 else { return 0.0 }
        return Double(currentTemp - globalMinTemp) / Double(globalRange)
    }
}

//#Preview {
//    DailyWeatherView().environmentObject(WeatherMapPlaceViewModel())
//}
