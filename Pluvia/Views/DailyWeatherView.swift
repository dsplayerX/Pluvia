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
        ScrollView {
            Text("8 Day Forecast Weather for current location)")
                .font(.title)
                .padding()

            Text("This is hard wired data - your data will be from api call safely unwrapped")
            VStack{
                Image("daily")
            }
        }
    }
}

#Preview {
    DailyWeatherView()
}
