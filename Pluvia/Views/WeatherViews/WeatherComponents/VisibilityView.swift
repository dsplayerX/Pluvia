//
//  VisibilityView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-26.
//

import SwiftUI

struct VisibilityView: View {
    var visibility: Int // in meters
    @Binding var useMetric: Bool // true if metric units are used

    private var description: String {
        if visibility/1000 >= 10 {
            return "Perfectly clear view."
        } else if visibility/1000 >= 8 {
            return "Good visibility."
        } else if visibility/1000 >= 4 {
            return "Moderate visibility."
        } else {
            return "Poor visibility."
        }
    }
    
    private var formattedVisibility: String {
            if useMetric {
                return "\(visibility / 1000) km"
            } else {
                let miles = Double(visibility) / 1609.34 // 1 mile = 1609.34 meters
                return String(format: "%.2f mi", miles)
            }
        }

    var body: some View {
        ZStack(alignment: .topLeading) {
            BlurBackground().cornerRadius(15)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))

                    Text("VISIBILITY")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(formattedVisibility)
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                }
                .padding(.top, 5)

                Text(description).font(.system(size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .padding(10)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    @Previewable @State var useMetric = false
    VisibilityView(visibility: 10000, useMetric: $useMetric)
        .padding()
}
