//
//  VisitedPlacesView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftData
import SwiftUI
struct VisitedPlacesView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    @State private var newCityName: String = ""

    var body: some View {
        VStack() {
            // Main Content
            VStack(alignment: .leading) {
                Text("Weather Locations")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            // Search bar and list go here
            HStack {
                TextField("Enter city name", text: $newCityName)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.thinMaterial)
                    .cornerRadius(5)
                    .padding(10)

                Button(action: {
                    Task {
                        weatherMapPlaceViewModel
                            .addLocation(cityName: newCityName.capitalized)
                        newCityName = ""
                    }
                }) {
                    Text("Add")
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.blue)
                        .cornerRadius(5)
                }
                .disabled(newCityName.isEmpty)
            }
            .padding(.horizontal, 20)

            List {
                ForEach(weatherMapPlaceViewModel.locations, id: \.name) { city in
                    HStack {
                        Text(city.name.capitalized)
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(city.latitude, specifier: "%.5f")° N, \(city.longitude, specifier: "%.5f")° W")
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                weatherMapPlaceViewModel.removeLocation(
                                    cityName: city.name
                                )
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.automatic)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
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

#Preview {
    do {
        // Create a temporary ModelContainer for preview purposes
        let container = try ModelContainer(for: LocationModel.self)

        // Initialize the ViewModel with the model context
        let viewModel = WeatherMapPlaceViewModel(
            modelContext: container.mainContext)

        // Mock data for preview
        viewModel.locations = [
            LocationModel(name: "London", latitude: 51.5074, longitude: -0.1278)
        ]

        return WeatherMainView()
            .environmentObject(viewModel)
            .modelContainer(container)
    } catch {
        fatalError(
            "Failed to create ModelContainer: \(error.localizedDescription)")
    }
}
