//
//  AveragesView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2025-01-11.
//

import SwiftUI

struct AveragesView: View {
    var temperatureDifference: Int // +2° above or below average
    var todayHigh: Int             // Today's high temperature
    var averageHigh: Int           // Average high temperature

    var body: some View {
        ZStack(alignment: .topLeading) {
            BlurBackground().cornerRadius(15)
            
            VStack(alignment: .leading) {
                // Title
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    Text("AVERAGES")                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Temperature difference
                Text("\(temperatureDifference > 0 ? "+" : "")\(temperatureDifference)°")
                    .font(.system(size: 36))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                // Description
                Text(temperatureDifference > 0 ?
                     "above average daily high" :
                     "below average daily high")
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer()
                
                // Today's high and average high
                VStack {
                    HStack() {
                        Text("Today")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("H:\(todayHigh)°")
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                                        
                    HStack() {
                        Text("Average")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()

                        Text("H:\(averageHigh)°")
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(10)
        }.aspectRatio(1, contentMode: .fit)
    }
}

struct AveragesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AveragesView(temperatureDifference: 2, todayHigh: 32, averageHigh: 30)
                .previewLayout(.sizeThatFits) // Adjusts to fit the content size
                .padding()
                .background(Color.blue) // Optional background for better visibility

            AveragesView(temperatureDifference: -3, todayHigh: 25, averageHigh: 28)
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color.black) // Simulating a dark mode environment
        }
    }
}
