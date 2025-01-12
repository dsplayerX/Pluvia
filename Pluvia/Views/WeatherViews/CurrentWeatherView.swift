//
//  CurrentWeatherView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import MapKit
import SwiftUI

struct CurrentWeatherView: View {
    @Binding var bgImageColor: Color

    var body: some View {
        VStack {
            TopWeatherView()
            HourlyWeatherView()
            DailyWeatherView()
            BottomTilesView(bgImageColor: $bgImageColor)
            Spacer()
            BottomInfoView()
        }.padding(.bottom, 20)
    }
}

struct BottomInfoView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    var body: some View {
        VStack(spacing: 10) {
            if weatherMapPlaceViewModel.weatherDataModel != nil {
                Divider().background(Color.white.opacity(0.7))
                HStack {
                    Button(
                        action: {
                            let currentLocationName = weatherMapPlaceViewModel
                                .currentLocation

                            if let location = weatherMapPlaceViewModel.locations
                                .first(where: { $0.name == currentLocationName }
                                )
                            {
                                let latitude = location.latitude
                                let longitude = location.longitude

                                // Create a destination in Maps
                                let destination = MKMapItem(
                                    placemark: MKPlacemark(
                                        coordinate: CLLocationCoordinate2D(
                                            latitude: latitude,
                                            longitude: longitude
                                        ),
                                        addressDictionary: nil
                                    )
                                )
                                destination.name = currentLocationName
                                destination.openInMaps(launchOptions: nil)  // Open Maps
                            } else {
                                print("Location not found in saved locations.")
                            }
                        }) {
                            HStack {
                                Text("Open in Maps")
                                Spacer()
                                Image(systemName: "arrow.up.right.square.fill")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 5)
                        }
                }

                Divider().background(Color.white.opacity(0.7))

                HStack {
                    Text("Learn more about")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Button(action: {
                        // Open OpenWeather website
                        if let url = URL(string: "https://openweathermap.org") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("weather data").underline()
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .background(.clear)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)

    }
}
