//
//  TopWeatherView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-20.
//


import SwiftUI

struct TopWeatherView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            if let weatherData = weatherMapPlaceViewModel.weatherDataModel {
                
                Text(weatherMapPlaceViewModel.currentLocation.capitalized)
                .foregroundColor(.white)
                .font(.system(size: 32))
                .shadow(radius: 10)
            
                
                Text(
                    "\(Int(weatherData.current.temp))°"
                )
                .foregroundColor(.white)
                .font(.system(size: 100))
                .fontWeight(.thin).shadow(radius: 10)
                
                Text(
                    "\(weatherData.current.weather[0].main.rawValue)"
                )
                .foregroundColor(Color.white)
                .opacity(0.9)
                    .font(.system(size: 20))
                    .fontWeight(.medium).shadow(radius: 10).padding(.top, -5)
                
                Text(
                    "H:\(Int(weatherData.daily[0].temp.max))° L:\(Int(weatherData.daily[0].temp.max))°"
                )
                .foregroundColor(.white)
                .font(.system(size: 20))
                .fontWeight(.medium).shadow(radius: 10).padding(.top, -5)
                
            } else {
                ProgressView("").foregroundColor(.white)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(3)
                    .shadow(radius: 10).padding(.top, 100)
            }
        }
        .padding()
}

}


//#Preview {
//    TopWeatherView().background(Color.blue).padding(.top, 50).environmentObject(WeatherMapPlaceViewModel())
//}
