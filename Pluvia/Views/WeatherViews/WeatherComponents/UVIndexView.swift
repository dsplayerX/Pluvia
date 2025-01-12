//
//  UVIndexView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-24.
//

import SwiftUI

struct UVIndexView: View {
    var uvIndex: Int

    private var gradientColors: [Color] {
        [
            Color.green,  // Low
            Color.yellow,  // Moderate
            Color.orange,  // High
            Color.red,  // Very High
            Color.purple,  // Extreme
        ]
    }

    private var uvColor: Color {
        switch uvIndex {
        case 0...2: return Color.green  // Low
        case 3...5: return Color.yellow  // Moderate
        case 6...7: return Color.orange  // High
        case 8...10: return Color.red  // Very High
        default: return Color.purple  // Extreme
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            BlurBackground().cornerRadius(15)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))

                    Text("UV INDEX")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("\(uvIndex)")
                        .font(.system(size: 36))
                        .foregroundColor(.white)

                    Text(getUVDescription(for: uvIndex))
                        .font(.system(size: 16))
                        .foregroundColor(uvColor)
                }

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: gradientColors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 5)

                    GeometryReader { geometry in
                        Circle()
                            .fill(.white)
                            .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 1)
                                )
                            .frame(width: 10, height: 10)
                            .offset(
                                x: CGFloat(uvIndex) / 11.0 * geometry.size.width
                                    - 6,
                                y: -1
                            )
                    }
                }
                .frame(height: 8)

                Text(getUVMessage(for: uvIndex))
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(
                        maxWidth: .infinity, maxHeight: .infinity,
                        alignment: .bottomLeading)
            }
            .padding(10)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func getUVDescription(for index: Int) -> String {
        switch index {
        case 0...2: return "Low"
        case 3...5: return "Moderate"
        case 6...7: return "High"
        case 8...10: return "Very High"
        default: return "Extreme"
        }
    }

    private func getUVMessage(for index: Int) -> String {
        switch index {
        case 0...2:
            return "Can safely stay outside."
        case 3...5:
            return "Stay in shade during midday."
        case 6...7:
            return "Avoid prolonged exposure."
        case 8...10:
            return "Take extra precautions."
        default:
            return "Use maximum sun protection."
        }
    }
}

#Preview {
    UVIndexView(uvIndex: 9)
        .padding().background(.blue)
}
