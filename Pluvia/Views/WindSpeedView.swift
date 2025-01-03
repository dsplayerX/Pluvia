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

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

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
                        Spacer()
                        HStack {
                            Text("Wind")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text("\(String(format: "%.1f", windSpeed)) km/h")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                            
                        Spacer()
                        if let gusts = windGusts {

                            HStack {
                                Text("Gusts")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("\(String(format: "%.1f", gusts)) km/h")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        HStack {
                            Text("Direction")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text(
                                "\(windDirection)° \(compassDirection(for: windDirection))"
                            )
                            .font(.caption)
                            .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.leading, 10)

                    Spacer()

                    VStack {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .rotationEffect(
                                Angle(degrees: Double(windDirection)))

                        // Wind speed in center
                        VStack(spacing: 2) {
                            Text("\(windSpeed, specifier: "%.1f")")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("km/h")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .frame(width: 120, height: 120)
                    .padding(.trailing, 15)
                }
            }.padding(10)
        }
        .aspectRatio(2.5, contentMode: .fit)
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

#Preview {
    WindSpeedView(windSpeed: 4.0, windGusts: 8.0, windDirection: 69)
        .padding()
}
