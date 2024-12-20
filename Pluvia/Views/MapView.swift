//
//  MapView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct MapView: View {

    // MARK:  set up the @EnvironmentObject for WeatherMapPlaceViewModel
        @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    
    var body: some View {
        VStack{
            Text("Image shows the information to be presented in this view")
            Spacer()
            Image("map")
                .resizable()


            Spacer()
        }
        .frame(height: 600)

    }
}

#Preview {
    MapView()
}
