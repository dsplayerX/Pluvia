//
//  AirPressureView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-24.
//

import SwiftUI

struct AirPressureView: View {
    var pressure: Int  // hPa
    var pressureRange: (low: Int, high: Int) = (980, 1050)  // Default range atmos pressure

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "gauge")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))

                    Text("PRESSURE")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                Text("\(pressure) hPa")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .padding(.top, 5)

                Spacer()

                HStack {
                    Text("Low")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7)).padding(5)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)

                            Capsule()
                                .fill(Color.blue)
                                .frame(
                                    width: geometry.size.width
                                        * CGFloat(
                                            (Double(
                                                pressure - pressureRange.low))
                                                / Double(
                                                    pressureRange.high
                                                        - pressureRange.low)),
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)

                    Text("High")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7)).padding(5)
                }
            }
            .padding(10)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    AirPressureView(pressure: 1011)
        .padding()
}
