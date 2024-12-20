//
//  ForecastWeatherView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct ForecastWeatherView: View {

    // MARK:  set up the @EnvironmentObject for WeatherMapPlaceViewModel
        @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel


    var body: some View {
        VStack(spacing: 5){

            HourlyWeatherView() // Similar to EPLClub Card
                .frame(height:250)
            DailyWeatherView() // Similar to EPLClub Row View

        }
        .frame(height: 600)
        // add modifiers and image to mirror the design required
    }
}

#Preview {
    ForecastWeatherView()
}
