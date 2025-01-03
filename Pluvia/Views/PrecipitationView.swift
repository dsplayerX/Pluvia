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

    private var description: String {
        if precipitationTomorrow > 0 {
            return "\(precipitationTomorrow) mm expected tomorrow."
        } else {
            return "No precipitation expected tomorrow."
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

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
                        Text("\(precipitationToday) mm")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                        Text("Today")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        Text("-- mm")
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
}

#Preview {
    PrecipitationView(precipitationToday: 10, precipitationTomorrow: 13)
        .padding()
}
