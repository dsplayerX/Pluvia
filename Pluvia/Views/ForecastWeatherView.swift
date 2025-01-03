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
    @Binding var bgImageColor: Color
    
    var body: some View {
        VStack(){
            HourlyWeatherView(bgImageColor: $bgImageColor)
            DailyWeatherView(bgImageColor: $bgImageColor)
        }
    }
}
