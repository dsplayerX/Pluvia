//
//  CurrentWeatherView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct CurrentWeatherView: View {
    
    // MARK:  set up the @EnvironmentObject for WeatherMapPlaceViewModel
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @Binding var bgImageColor: Color

    // MARK:  set up local @State variable to support this view
    var body: some View {
        TopWeatherView()
        ForecastWeatherView()
        BottomTilesView(bgImageColor: $bgImageColor)
    }
}

