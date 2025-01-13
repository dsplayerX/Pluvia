//
//  FeelsLikeView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-22.
//

import SwiftUI

struct FeelsLikeView: View {
    var feelsLikeTemp: Int
    var currentTemp: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            BlurBackground().cornerRadius(15)
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "thermometer")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))

                    Text("FEELS LIKE")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                }

                Text("\(feelsLikeTemp)°")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .padding(.top, 5)

                Spacer()

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

            }
            .padding(10)
        }.aspectRatio(1, contentMode: .fit)
    }
    
    // Get the description for the feels like temperature
    private var description: String {
        let difference = feelsLikeTemp - currentTemp
        switch difference {
        case Int.min..<(-3):
            return "Feels much colder than the actual temperature."
        case -3..<0:
            return "Slightly cooler than the actual temperature."
        case 0:
            return "Similar to the actual temperature."
        case 1...3:
            return "Slightly warmer than the actual temperature."
        default:
            return "Feels much warmer than the actual temperature."
        }
    }
}

#Preview {
    FeelsLikeView(feelsLikeTemp: 29, currentTemp: 30)
        .padding().background(.blue)
}
