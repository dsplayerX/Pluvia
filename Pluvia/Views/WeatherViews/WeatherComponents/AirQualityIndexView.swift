//
//  AirComponentView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-23.
//


//
//  AirComponentView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-22.
//

import SwiftUI

struct AirQualityIndexView: View {
    var value: Int
    @Binding var bgImageColor: Color

    var body: some View {
        ZStack(alignment: .topLeading) {
            BlurBackground().cornerRadius(15)

            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "aqi.medium")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))

                    Text("AQI")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                }

                Text("\(value)")
                    .font(.system(size: 36))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.top, 5)

                Spacer()

                Text(getAQIDescription(for: value))
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(10)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    // Get the description for the AQI value
    private func getAQIDescription(for value: Int) -> String {
           switch value {
           case 1:
               return "Good air quality."
           case 2:
               return "Fair air quality."
           case 3:
               return "Moderate air quality."
           case 4:
               return "Poor air quality."
           case 5:
               return "Very poor air quality."
           default:
               return "Unknown air quality index."
           }
       }
}

#Preview {
    AirQualityIndexView(value: 2, bgImageColor: .constant(.green))
        .padding()
}
