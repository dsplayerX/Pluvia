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

        let globalMinTemp =
            weatherData.daily.prefix(7).map { $0.temp.min }.min() ?? 0.0
        let globalMaxTemp =
            weatherData.daily.prefix(7).map { $0.temp.max }.max() ?? 0.0
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
                    currentTemp: currentTemp,
                    useMetric: weatherMapPlaceViewModel.useMetric)
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
    let useMetric: Bool

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
                    .font(.system(size: 20)).fontWeight(.medium).frame(
                        width: 40)

                TempBarView(
                    index: index,
                    minTemp: day.temp.min,
                    maxTemp: day.temp.max,
                    globalMinTemp: globalMinTemp,
                    globalMaxTemp: globalMaxTemp,
                    currentTemp: currentTemp,
                    useMetric: useMetric
                )
                .frame(width: 80, height: 5)
                .padding(.horizontal, 5)

                // Maximum temperature
                Text("\(Int(day.temp.max))°")
                    .foregroundColor(.white)
                    .font(.system(size: 20)).fontWeight(.medium).frame(
                        width: 40)
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
    let useMetric: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                Capsule()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 5)

                // Temperature gradient
                LinearGradient(
                    gradient: Gradient(
                        colors: generateGradientColors(
                            minTemp: minTemp, maxTemp: maxTemp)),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(
                    width: calculateBarWidth(geometry.size.width),
                    height: 5
                )
                .clipShape(Capsule())
                .offset(x: calculateBarOffset(geometry.size.width))  // How much to offset the gradient

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

    // Calculate the width of the temperature bar
    private func calculateBarWidth(_ width: CGFloat) -> CGFloat {
        let range = globalMaxTemp - globalMinTemp
        guard range > 0 else { return width }
        let tempRange = maxTemp - minTemp
        return CGFloat(tempRange / range) * width
    }

    // Calculate the offset of the temperature bar
    private func calculateBarOffset(_ width: CGFloat) -> CGFloat {
        let range = globalMaxTemp - globalMinTemp
        guard range > 0 else { return 0 }
        let distanceFromMin = minTemp - globalMinTemp
        return CGFloat(distanceFromMin / range) * width
    }

    // Calculate the position of the current temperature dot
    private var calculateDotPosition: CGFloat {
        let range = globalMaxTemp - globalMinTemp
        guard range > 0 else { return 0 }
        return CGFloat((currentTemp - globalMinTemp) / range)
    }

    private func generateGradientColors(minTemp: Double, maxTemp: Double)
        -> [Color]
    {
        // Define temperature thresholds and corresponding colors
        let thresholdsCelcius: [(temp: Double, color: Color)] =
            [
                (temp: -10, color: Color.purple),  // Below -10°C
                (temp: 0, color: Color.blue),  // 0°C to 10°C
                (temp: 10, color: Color.cyan),  // 10°C to 15°C
                (temp: 15, color: Color.green),  // 15°C to 20°C
                (temp: 20, color: Color.yellow),  // 20°C to 25°C
                (temp: 25, color: Color.orange),  // 25°C to 30°C
                (temp: 30, color: Color.red),  // Above 30°C
            ]

        let thresholdsFahrenheit: [(temp: Double, color: Color)] =
            [
                (temp: 14, color: Color.purple),  // Below 14°F
                (temp: 32, color: Color.blue),  // 32°F to 50°F
                (temp: 50, color: Color.cyan),  // 50°F to 59°F
                (temp: 59, color: Color.green),  // 59°F to 68°F
                (temp: 68, color: Color.yellow),  // 68°F to 77°F
                (temp: 77, color: Color.orange),  // 77°F to 86°F
                (temp: 86, color: Color.red),  // Above 86°F
            ]
        
        let thresholds = useMetric ? thresholdsCelcius : thresholdsFahrenheit

        // Ensure valid temperature range
        guard maxTemp > minTemp else {
            return [Color.gray]  // Fallback neutral color
        }

        // Filter relevant thresholds based on the actual temperature range
        let filteredThresholds = thresholds.filter {
            $0.temp >= minTemp && $0.temp <= maxTemp
        }

        // Fallback: Includes the nearest lower or upper threshold if no direct match
        let lowerBound =
            thresholds.last(where: { $0.temp <= minTemp }) ?? thresholds.first!
        let upperBound =
            thresholds.first(where: { $0.temp >= maxTemp }) ?? thresholds.last!
        let relevantThresholds =
            [lowerBound] + filteredThresholds + [upperBound]

        // Get the colors from the relevant thresholds
        return relevantThresholds.map { $0.color }
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: LocationModel.self)

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
