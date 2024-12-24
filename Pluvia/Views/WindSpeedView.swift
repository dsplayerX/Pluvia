//
//  WindSpeedView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-24.
//

import SwiftUI

struct WindSpeedView: View {
    var windSpeed: Double // Wind speed value
    var windGusts: Double? // Optional gusts value
    var windDirection: Int // Wind direction in degrees

    var body: some View {
        ZStack {
            // Background card
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

            HStack {
                // Left side details
                VStack(alignment: .leading, spacing: 10) {
                    headerRow(label: "Wind", value: "\(String(format: "%.1f", windSpeed)) km/h")
                    if let gusts = windGusts {
                        headerRow(label: "Gusts", value: "\(String(format: "%.1f", gusts)) km/h")
                    }
                    headerRow(label: "Direction", value: "\(windDirection)° \(compassDirection(for: windDirection))")
                }
                .padding(.leading, 15)

                Spacer()

                // Compass
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 100, height: 100)

                    ForEach(0..<4) { i in
                        Text(compassDirection(for: i * 90))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .position(x: 50 + CGFloat(cos(Double(i) * .pi / 2)) * 45,
                                      y: 50 - CGFloat(sin(Double(i) * .pi / 2)) * 45)
                    }

                    Image(systemName: "arrow.up")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .rotationEffect(Angle(degrees: Double(windDirection)))

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
        }
        .aspectRatio(2.5, contentMode: .fit)
    }

    // Helper function to display rows
    private func headerRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.white)
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

#Preview {
    WindSpeedView(windSpeed: 4.0, windGusts: 8.0, windDirection: 69)
        .padding()
}
