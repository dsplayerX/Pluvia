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
        VStack (alignment: .leading){
            HStack {
                Image(systemName: "calendar")
                Text("10-Day Forecast")
            }
            Divider().background(Color.white)
                    ForEach(0..<5) { day in
                        HStack () {
                            Text(day == 0 ? "Today" : "Day \(day + 1)")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            Spacer()
                            
                            Image(systemName: "cloud.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                            
                            Spacer()
                            
                            Text("24°")
                                .foregroundColor(.white)
                                .font(.caption)
                            
                            TempLowHighProgressView()
                            
                            Text("32°")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .padding(.vertical, 5)
                    }
        }.padding(10).background(Color.blue.opacity(0.9)).cornerRadius(10).padding(10)
    }
}

#Preview {
    DailyWeatherView()
}

struct TempLowHighProgressView: View {
    var body: some View {
        
//        var ranger: ClosedRange<Double> = 0...1
        
        ProgressView(value: 0.6, total: 1)
            .progressViewStyle(LinearProgressViewStyle())
            .accentColor(.white)
    }
}
