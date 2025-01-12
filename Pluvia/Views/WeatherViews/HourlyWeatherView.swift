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
        if let weatherData = weatherMapPlaceViewModel.weatherDataModel {
            ZStack {
                BlurBackground()
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 2.5)

                VStack(alignment: .leading) {
                    Text("\(weatherData.daily[0].summary).")
                        .foregroundColor(.white)
                        .font(.system(size: 14)).padding(.vertical, 5)

                    Divider().background(Color.white)

                    HourlyWeatherListView(weatherData: weatherData)
                }
                .frame(minHeight: 150)
                .padding(10)
                .cornerRadius(15)
                .padding(.horizontal, 20)
                .padding(.vertical, 2.5)
            }
        }
    }
}

struct HourlyWeatherListView: View {
    var weatherData: WeatherDataModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 20) {
                ForEach(weatherData.hourly, id: \.id) { hour in
                    VStack(alignment: .center) {
                        if hour.id == weatherData.hourly.first?.id {
                            Text("Now")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                                .padding(.top, 5)
                                .padding(.bottom, 10)
                        } else {
                            Text(
                                DateFormatterUtils.formattedDynamicHour(
                                    from: TimeInterval(hour.dt),
                                    timeZone: TimeZone(
                                        identifier: weatherData.timezone)
                                        ?? .current
                                )
                            )
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                        }
                        Spacer()
                        
                        HourlyWeatherIconView(
                            conditionID: hour.weather[0].id,
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
        VStack(alignment: .center) {
            Image(
                systemName: mapWeatherIcon(
                    for: conditionID,
                    dt: dt,
                    timezone: timezone
                )
            )
            .resizable()
            .scaledToFit()
            .frame(height: 24).frame(width: 24)
            .aspectRatio(contentMode: .fit)
            .symbolRenderingMode(.multicolor)  // multi-color rendering
            .foregroundColor(.white)
            .padding(.bottom, 0)

            if let pop = pop, pop > 0 {
                Text("\(Int(pop * 100))%")
                    .foregroundColor(.cyan)
                    .font(.system(size: 10))
                    .padding(.top, -8)
            }
        }.frame(height: 40)
            .frame(maxWidth: .infinity)
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
