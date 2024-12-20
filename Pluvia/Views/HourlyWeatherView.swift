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
        ScrollView {
            Text("Hourly Forecast Weather for current location)")
                .font(.title)
                .padding()

            Text("This is hard wired data - your data will be from api call safely unwrapped")
            ScrollView(.horizontal,showsIndicators: false){

                Image("hourly")

            }
        }
    }
}
#Preview {
    HourlyWeatherView()
}
