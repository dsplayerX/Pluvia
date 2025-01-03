//
//  TileViews.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-22.
//

import SwiftUI

struct BottomTilesView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @Binding var bgImageColor: Color

    var body: some View {

        VStack {
            if let weatherData = weatherMapPlaceViewModel.weatherDataModel {
                HStack {
                    FeelsLikeView(
                        feelsLikeTemp: Int(weatherData.current.feelsLike),
                        currentTemp: Int(weatherData.current.temp)
                    )
                    HumidityView(
                        humidity: weatherData.current.humidity,
                        dewPiont: weatherData.current.dewPoint
                    )
                }.padding(.horizontal, 20).padding(.vertical, 2.5)

                HStack {
                    SunriseSunsetView(
                        sunriseTimestamp: Int(weatherData.current.sunrise!),
                        sunsetTimestamp: Int(weatherData.current.sunset!),
                        timezone: weatherData.timezone
                    )
                }.padding(.horizontal, 20).padding(.vertical, 2.5)

                HStack {
                    UVIndexView(uvIndex: Int(weatherData.current.uvi))
                    AirPressureView(
                        pressure: Int(weatherData.current.pressure)
                    )
                }.padding(.horizontal, 20).padding(.vertical, 2.5)

                HStack {
                    PrecipitationView(
                        precipitationToday: Int(
                            weatherData
                                .daily[0].rain ?? -1),
                        precipitationTomorrow: Int(
                            weatherData
                                .daily[1].rain ?? -1)
                    )

                    VisibilityView(visibility: weatherData.current.visibility)

                }.padding(.horizontal, 20).padding(.vertical, 2.5)
                
                //                    WindSpeedView(
                //                        windSpeed: 23,
                //                        windDirection: 30
                //                    )
                //                        .padding(.horizontal, 20)
                //                        .padding(.vertical, 2.5)
            }

            if let airData = weatherMapPlaceViewModel.airDataModel {
                AirDataCollectionView(airData: airData, bgImageColor: $bgImageColor)
                    .background(.ultraThinMaterial).cornerRadius(15)
                    .padding(.horizontal, 20).padding(.vertical, 2.5)
            }
        }

    }
}

//#Preview {
//    BottomTilesView()
//}
