//
//  TopWeatherView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-20.
//


import SwiftUI

struct TopWeatherView: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text("London")
                .font(.body)
                .bold()
            Text("24")
                .font(.system(size: 40))
            Text("Mostly Cloudy")
                .font(.body)
            Text("H: 72 L: 55")
                .font(.caption2)
                .bold()
            Spacer()
        }
        .padding()
        .background(Color.white)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
}

}


#Preview {
    TopWeatherView()
}
