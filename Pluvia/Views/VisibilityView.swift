//
//  VisibilityView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-26.
//

import SwiftUI

struct VisibilityView: View {
    var visibility: Int // in meters

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

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

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
                    Text("\(visibility/1000) km")
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
    VisibilityView(visibility: 10000)
        .padding()
}
