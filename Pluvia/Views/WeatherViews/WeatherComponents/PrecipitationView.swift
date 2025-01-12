//
//  PrecipitationView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-26.
//

import SwiftUI

struct PrecipitationView: View {
    var precipitationToday: Int // Precipitation in mm for today
    var precipitationTomorrow: Int // Precipitation in mm for tomorrow
    @Binding var useMetric: Bool // Use metric (mm) or imperial (inches)

    private var description: String {
        let tomorrowPrecipitation = formattedPrecipitation(precipitationTomorrow)
        if precipitationTomorrow > 0 {
            return "\(tomorrowPrecipitation) expected tomorrow."
        } else {
            return "No precipitation expected tomorrow."
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            BlurBackground().cornerRadius(15)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))

                    Text("PRECIPITATION")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    if precipitationToday != -1 {
                        Text("\(formattedPrecipitation(precipitationToday))")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                        Text("Today")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        Text("-- \(unitLabel())")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 5)

                if precipitationTomorrow != -1 {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
            }
            .padding(10)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func formattedPrecipitation(_ precipitation: Int) -> String {
        if useMetric {
            return "\(precipitation) mm"
        } else {
            let inches = Double(precipitation) / 25.4 // 1 inch = 25.4 mm
            return String(format: "%.2f in", inches)
        }
    }

    private func unitLabel() -> String {
        return useMetric ? "mm" : "in"
    }
}

#Preview {
    @Previewable @State var useMetric = false
    PrecipitationView(precipitationToday: 10, precipitationTomorrow: 13, useMetric: $useMetric)
        .padding()
}
