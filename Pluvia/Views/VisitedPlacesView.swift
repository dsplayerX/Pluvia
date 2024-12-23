//
//  VisitedPlacesView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct VisitedPlacesView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    @State private var newCityName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // Search bar to add new cities
                HStack {
                    TextField("Enter city name", text: $newCityName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 10)

                    Button(action: {
                        Task {
                            weatherMapPlaceViewModel
                                .addLocation(cityName: newCityName.capitalized)
                                newCityName = ""
                            
                        }
                    
                    }) {
                        Text("Add")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    .disabled(newCityName.isEmpty)
                }
                .padding()

                // List of saved cities
                List {
                    ForEach(weatherMapPlaceViewModel.locations, id: \.name) { city in
                        HStack {
                            Text(city.name.capitalized)
                            Spacer()
                            VStack (alignment:.leading){
                                Text("LON: \(city.latitude, specifier: "%.4f")")
                                Text("LAT: \(city.longitude, specifier: "%.4f")")
                            }
                            
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                Task {
                                    weatherMapPlaceViewModel.removeLocation(cityName: city.name)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .navigationTitle("Saved Cities")
            }
            .alert(item: $weatherMapPlaceViewModel.errorMessage) { errorMessage in
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage.message),
                    dismissButton: .default(Text("OK")) {
                        weatherMapPlaceViewModel.errorMessage = nil
                    }
                )
            }
        }
    }
}
