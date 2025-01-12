//
//  WindSpeedView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-24.
//

import SwiftUI

struct WindSpeedView: View {
    var windSpeed: Double  // Wind speed value
    var windGusts: Double?  // Optional gusts value
    var windDirection: Int  // Wind direction in degrees
    @Binding var useMetric: Bool  // Metric or Imperial toggle

    var body: some View {
        ZStack(alignment: .topLeading) {
            BlurBackground()
                .cornerRadius(15)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "wind")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))

                    Text("WIND")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                }

                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Wind")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(formattedSpeed(windSpeed))")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        Divider()
                        if let gusts = windGusts {
                            HStack {
                                Text("Gusts")
                                    .font(.system(size: 14)).foregroundColor(
                                        .white)
                                Spacer()
                                Text("\(String(format: "%.1f", gusts)) km/h")
                                    .font(.system(size: 14)).foregroundColor(
                                        .white)
                            }
                            Divider()
                        }
                        HStack {
                            Text("Direction")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            Spacer()
                            Text(
                                "\(windDirection)° \(compassDirection(for: windDirection))"
                            )
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        }
                    }

                    Spacer()

                    CompassView(windDirection: windDirection)
                        .frame(width: 120, height: 120)
                        .padding(.leading, 20)
                        .padding(.trailing, 15)
                        .padding(.vertical, 5)
                }
            }
            .padding(10)
        }
        .aspectRatio(2.5, contentMode: .fit)
    }
    
    private func formattedSpeed(_ speed: Double) -> String {
           if useMetric {
               return "\(String(format: "%.1f", speed)) km/h"
           } else {
               let mph = speed * 0.621371
               return "\(String(format: "%.1f", mph)) mph"
           }
       }

    private func compassDirection(for degrees: Int) -> String {
        switch degrees {
        case 0...22, 338...360: return "N"
        case 23...67: return "NE"
        case 68...112: return "E"
        case 113...157: return "SE"
        case 158...202: return "S"
        case 203...247: return "SW"
        case 248...292: return "W"
        case 293...337: return "NW"
        default: return ""
        }
    }
}


struct CompassView: View {
    var windDirection: Int // Wind direction in degrees

    var body: some View {
        ZStack(alignment: .center) {
            // Compass Circle
            Circle()
                .strokeBorder(
                    Color.white.opacity(0.3),
                    lineWidth: 2
                )
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )
                .frame(width: 120, height: 120)

            // Cardinal Directions
            VStack {
                Text("N")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Text("S")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.vertical, 10)

            HStack {
                Text("W")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Text("E")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)

            // Arrow for Wind Direction
            Image(systemName: "arrow.up")
                .resizable()
                .aspectRatio(0.4, contentMode: .fit)
                .foregroundColor(.white)
                .rotationEffect(
                    Angle(degrees: Double(windDirection)),
                    anchor: .center
                )
                .frame(width: 30, height: 30)
        }
    }
}

#Preview {
    @Previewable @State var useMetric = false
    WindSpeedView(windSpeed: 4.0, windGusts: 8.0, windDirection: 69, useMetric: $useMetric)
        .padding()
}
