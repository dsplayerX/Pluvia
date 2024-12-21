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
                Text("Cloudy conditions expected around 00:30. Wind gusts are up to 11 km/h.")
                    .foregroundColor(.white)
                    .font(.caption)
                
                Divider().background(Color.white)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(0..<6) { hour in
                            VStack {
                                Text(hour == 0 ? "Now" : "\(hour * 1):00")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                
                                Image(systemName: "cloud.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                
                                Text("25°")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
//                            .padding()
                        }
                    }
                }
            }
            .padding(10)
            .background(Color.blue.opacity(0.9))
            .cornerRadius(10)
            .padding(10)
        }
}
#Preview {
    HourlyWeatherView()
}
