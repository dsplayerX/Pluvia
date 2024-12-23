//
//  TileViews.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-22.
//

import SwiftUI

struct BottomTilesView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    var body: some View {
       
            VStack{
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
                }
                
                if let airData = weatherMapPlaceViewModel.airDataModel {
                    AirDataCollectionView(airData: airData)
                        .background(.ultraThinMaterial).cornerRadius(15)
                        .padding(.horizontal, 20).padding(.vertical, 2.5)
                }
            }
        
    }
}

#Preview {
    BottomTilesView()
}
