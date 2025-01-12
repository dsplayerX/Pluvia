//
//  DailyWeatherView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftData
import SwiftUI

struct DailyWeatherView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    var body: some View {
        if let weatherData = weatherMapPlaceViewModel.weatherDataModel {
            ZStack {
                BlurBackground().cornerRadius(15)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 2.5)

                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "calendar").foregroundColor(
                            Color.white.opacity(0.7))
                        Text("7-DAY FORECAST").foregroundColor(
                            Color.white.opacity(0.7)
                        ).font(.system(size: 14))
                    }
                    Divider().background(Color.white)
                    forecastListView(weatherData: weatherData)
                }
                .padding()
                .cornerRadius(15)
                .padding(.horizontal, 20)
                .padding(.vertical, 2.5)

            }
        }
    }

    private func forecastListView(weatherData: WeatherDataModel) -> some View {

        let globalMinTemp = weatherData.daily.map { $0.temp.min }.min() ?? 0.0
        let globalMaxTemp = weatherData.daily.map { $0.temp.max }.max() ?? 0.0
        let currentTemp = weatherData.current.temp
        return VStack {

            ForEach(
                Array(weatherData.daily.prefix(7).enumerated()),
                id: \.element.id
            ) { index, day in
                if index != 0 {
                    Divider()
                }
                DailyWeatherRowView(
                    index: index, day: day, timezone: weatherData.timezone,
                    globalMinTemp: globalMinTemp,
                    globalMaxTemp: globalMaxTemp,
                    currentTemp: currentTemp)
            }
        }
    }
}

struct DailyWeatherRowView: View {
    let index: Int
    let day: Daily
    let timezone: String
    let globalMinTemp: Double
    let globalMaxTemp: Double
    let currentTemp: Double

    var body: some View {
        HStack(spacing: 10) {
            Text(index == 0 ? "Today" : formatDayLabel(for: day.dt))
                .foregroundColor(.white)
                .font(.system(size: 16)).fontWeight(.medium)
                .frame(width: 60, alignment: .leading)

            Spacer()

            VStack(alignment: .leading) {
                Image(
                    systemName: mapWeatherIcon(
                        for: day.weather[0].id, dt: day.dt,
                        timezone: timezone)
                ).symbolRenderingMode(.multicolor)
                    .font(.system(size: 20))
                if day.pop > 0 {
                    Text("\(Int(day.pop * 100))%")
                        .foregroundColor(.cyan)
                        .font(.system(size: 12))
                }
            }.frame(width: 40)

            Spacer()

            // Minimum temperature
            HStack {
                Text("\(Int(day.temp.min))°")
                    .foregroundColor(.white)
                    .font(.system(size: 20)).fontWeight(.medium)

                TempBarView(
                    index: index,
                    minTemp: Double(Int(day.temp.min)),
                    maxTemp: Double(Int(day.temp.max)),
                    globalMinTemp: Double(Int(globalMinTemp)),
                    globalMaxTemp: Double(Int(globalMaxTemp)),
                    currentTemp: Double(
                        Int(
                            index == 0
                                ? currentTemp
                                : (day.temp.min + day.temp.max) / 2
                        ))
                )
                .frame(height: 5)
                .padding(.horizontal, 5)

                // Maximum temperature
                Text("\(Int(day.temp.max))°")
                    .foregroundColor(.white)
                    .font(.system(size: 20)).fontWeight(.medium)
            }
            .padding(.horizontal, 5)
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
}

struct TempBarView: View {
    let index: Int
    let minTemp: Double
    let maxTemp: Double
    let globalMinTemp: Double
    let globalMaxTemp: Double
    let currentTemp: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                Capsule()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 5)

                // Temperature gradient
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .orange, .red]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(
                    width: calculateBarWidth(geometry.size.width),
                    height: 5
                )
                .clipShape(Capsule())
                .offset(x: calculateBarOffset(geometry.size.width))

                // Current temperature dot
                if index == 0 {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .position(
                            x: geometry.size.width * calculateDotPosition,
                            y: 5 / 2
                        )
                }
            }
        }
    }

    private func calculateBarWidth(_ width: CGFloat) -> CGFloat {
        let range = globalMaxTemp - globalMinTemp
        guard range > 0 else { return width }
        let tempRange = maxTemp - minTemp
        return CGFloat(tempRange / range) * width
    }

    private func calculateBarOffset(_ width: CGFloat) -> CGFloat {
        let range = globalMaxTemp - globalMinTemp
        guard range > 0 else { return 0 }
        let distanceFromMin = minTemp - globalMinTemp
        return CGFloat(distanceFromMin / range) * width
    }

    private var calculateDotPosition: CGFloat {
        let range = globalMaxTemp - globalMinTemp
        guard range > 0 else { return 0 }
        return CGFloat((currentTemp - globalMinTemp) / range)
    }
}

#Preview {
    do {
        // Create a temporary ModelContainer for preview purposes
        let container = try ModelContainer(for: LocationModel.self)

        // Initialize the ViewModel with the model context
        let viewModel = WeatherMapPlaceViewModel(
            modelContext: container.mainContext)

        // Mock data for preview
        viewModel.locations = [
            LocationModel(name: "London", latitude: 51.5074, longitude: -0.1278)
        ]

        return WeatherMainView()
            .environmentObject(viewModel)
            .modelContainer(container)
    } catch {
        fatalError(
            "Failed to create ModelContainer: \(error.localizedDescription)")
    }
}
