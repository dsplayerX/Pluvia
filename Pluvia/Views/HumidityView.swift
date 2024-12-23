//
//  HumidityView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-22.
//

//
//  HumidityView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-22.
//

import SwiftUI

struct HumidityView: View {
    var humidity: Int
    var dewPiont: Double

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "humidity.fill")
                        .font(.system(size: 14)).foregroundColor(
                            Color.white.opacity(0.7))

                    Text("HUMIDITY")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                }

                Text("\(humidity)%")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .padding(.top, 5)

                Spacer()

                Text("The dew point is \(dewPiont, specifier: "%.1f")° right now.")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(10)
        }.aspectRatio(1, contentMode: .fit)

    }
}

#Preview {
    HumidityView(humidity: 70, dewPiont: 50)
        .padding()
}
