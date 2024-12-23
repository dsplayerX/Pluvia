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

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "aqi.high")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))

                    Text("AQI")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                }

                Text("\(value)")
                    .font(.system(size: 36))
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
        .aspectRatio(1, contentMode: .fit).frame(maxHeight: 180)
    }
    
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
    AirQualityIndexView(value: 2)
        .padding()
}
