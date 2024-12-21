//
//  VisitedPlacesView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct VisitedPlacesView: View {
/*
    Set up the @Environment(\.modelContext) for SwiftData's Model Context
    Use @Query to fetch data from SwiftData models
*/
    
    let cities: [City]
    
    var body: some View {       
            NavigationView {
                List {
                    ForEach(cities, id: \.name) { city in
                        HStack {
                            Text(city.name)
                            Spacer()
                        }
                    }
                }
                .navigationTitle("Saved Cities")
            }
    }
}

#Preview {
    VisitedPlacesView(cities: [City(name: "London"), City(name: "Paris")])
}
