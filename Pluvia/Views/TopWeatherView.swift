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
                
            Text(weatherMapPlaceViewModel.newLocation)
                .foregroundColor(.white)
                .font(.system(size: 32))
                .shadow(radius: 10)
            
                
                Text(
                    "\(Int( weatherMapPlaceViewModel.weatherDataModel!.current.temp))°"
                )
                .foregroundColor(.white)
                .font(.system(size: 100))
                .fontWeight(.thin).shadow(radius: 10)
                
                Text(
                    "\(weatherMapPlaceViewModel.weatherDataModel!.current.weather[0].main.rawValue)"
                )
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                    .fontWeight(.medium).shadow(radius: 10)
                
                Text(
                    "H:\(Int(weatherMapPlaceViewModel.weatherDataModel!.daily[0].temp.max))° L:\(Int(weatherMapPlaceViewModel.weatherDataModel!.daily[0].temp.max))°"
                )
                .foregroundColor(.white)
                .font(.system(size: 18))
                .fontWeight(.medium).shadow(radius: 10)
                
            } else {
                ProgressView("").foregroundColor(.white)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(4)
                    .shadow(radius: 10).padding(.top, 100)
            }
        }
        .padding()
}

}


#Preview {
    TopWeatherView().background(Color.blue).padding(.top, 50).environmentObject(WeatherMapPlaceViewModel())
}
