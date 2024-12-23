//
//  AirDataCollectionView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-23.
//

import SwiftUI

struct AirDataCollectionView: View {

    var airData: AirDataModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "aqi.low")
                    .foregroundColor(Color.white.opacity(0.7))
                    .font(.system(size: 14))
                Text("AIR QUALITY")
                    .font(.system(size: 14))
                    .foregroundColor(Color.white.opacity(0.7))
            }.padding(.horizontal, 10).padding(.top, 10)

            HStack() {
                AirQualityIndexView(
                    value: airData.list[0].main.aqi
                )
                VStack{
                    ForEach(getComponents(), id: \.0) { component in
                        HStack {
                            Image(systemName: component.1)
                                .foregroundColor(.white)
                                .font(.system(size: 14)).frame(minWidth: 20)
                            Text(component.0)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                            Spacer()
                            Text("\(component.2, specifier: "%.2f")")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                    }
                    HStack{
                        Spacer()
                        Text("measured in µg/m³")
                            .foregroundColor(.white)
                            .font(.system(size: 12)).padding(.top, 10)
                    }.padding(.top, -15)
                }.padding(.horizontal, 10)
            }.padding(10)
        }
    }

    private func getComponents() -> [(String, String, Double)] {
        guard let airComponents = airData.list.first?.components else {
            return []
        }

        return [
            ("CO", "wind", airComponents.co),
            ("NO", "flame.fill", airComponents.no),
            ("NO₂", "cloud.sun.bolt.fill", airComponents.no2),
            ("O₃", "sun.max.circle.fill", airComponents.o3),
            ("SO₂", "cloud.fog.fill", airComponents.so2),
            ("PM₂.₅", "aqi.low", airComponents.pm2_5),
            ("PM₁₀", "aqi.medium", airComponents.pm10),
            ("NH₃", "leaf.arrow.circlepath", airComponents.nh3),
        ]
    }

}
//
//#Preview {
//    AirDataCollectionView()
//}
